from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import random

from app.database import get_db
from app.models import Report, Zone, AuditLog, Alert
from app.schemas import ReportCreate, ReportResponse, ReportVerify
from app.risk_engine import calculate_landslide_risk

router = APIRouter(prefix="/api/reports", tags=["Citizen & Field Reports"])

@router.get("", response_model=List[ReportResponse])
def get_reports(db: Session = Depends(get_db)):
    return db.query(Report).order_by(Report.timestamp.desc()).all()

@router.post("", response_model=ReportResponse)
def submit_report(report_in: ReportCreate, db: Session = Depends(get_db)):
    # Generate code e.g. TG-RPT-1088
    rpt_code = f"TG-RPT-{random.randint(1050, 9999)}"
    
    # Try to find matching zone by district or location
    matched_zone = None
    if report_in.zone_id:
        matched_zone = db.query(Zone).filter(Zone.id == report_in.zone_id).first()
    else:
        matched_zone = db.query(Zone).filter(Zone.district == report_in.district).first()
    
    lat = report_in.latitude or (matched_zone.latitude + random.uniform(-0.02, 0.02) if matched_zone else 25.5788)
    lng = report_in.longitude or (matched_zone.longitude + random.uniform(-0.02, 0.02) if matched_zone else 91.8933)

    db_report = Report(
        report_code=rpt_code,
        reporter_type=report_in.reporter_type,
        district=report_in.district,
        location_name=report_in.location_name,
        latitude=lat,
        longitude=lng,
        issue_type=report_in.issue_type,
        severity=report_in.severity,
        description=report_in.description,
        photo_url=report_in.photo_url or "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80",
        timestamp=datetime.utcnow(),
        status="Pending Verification",
        zone_id=matched_zone.id if matched_zone else None
    )

    db.add(db_report)
    
    # Add audit log
    audit = AuditLog(
        event_type="Report Received",
        zone_name=matched_zone.name if matched_zone else report_in.district,
        details=f"New {report_in.reporter_type} report {rpt_code} ({report_in.issue_type} - {report_in.severity}) received.",
        action_by=f"{report_in.reporter_type} User"
    )
    db.add(audit)

    db.commit()
    db.refresh(db_report)
    return db_report

@router.patch("/{report_id}/verify")
def verify_report(report_id: int, verify_in: ReportVerify, db: Session = Depends(get_db)):
    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    report.status = verify_in.status
    report.verified_by = verify_in.verified_by

    # If verified or escalated, update affected zone's field reports and recalculate risk!
    if verify_in.status in ["Verified", "Escalated"] and report.zone_id:
        zone = db.query(Zone).filter(Zone.id == report.zone_id).first()
        if zone:
            zone.field_reports_count += 1
            
            # Recalculate risk score with updated field reports
            calc = calculate_landslide_risk(
                rainfall=zone.rainfall,
                soil_moisture=zone.soil_moisture,
                slope=zone.slope,
                historical_risk=zone.historical_risk,
                satellite_change=zone.satellite_change,
                field_reports=zone.field_reports_count
            )
            
            prev_level = zone.risk_level
            zone.risk_score = calc["riskScore"]
            zone.risk_level = calc["riskLevel"]
            zone.recommended_action = calc["recommendation"]
            zone.last_updated = datetime.utcnow()

            # If risk crossed to EVACUATE/WARNING, generate alert
            if zone.risk_level in ["WARNING", "EVACUATE"] and zone.risk_level != prev_level:
                alert_code = f"TG-ALT-{random.randint(1050, 9999)}"
                new_alert = Alert(
                    alert_code=alert_code,
                    zone_id=zone.id,
                    zone_name=zone.name,
                    district=zone.district,
                    risk_score=zone.risk_score,
                    alert_level=zone.risk_level,
                    trigger_reason=f"Verified High-Severity Field Report ({report.issue_type})",
                    timestamp=datetime.utcnow(),
                    recipients="District Admin, Local Field Officers",
                    status="Active",
                    acknowledged=False,
                    sms_sent=True,
                    ivr_activated=(zone.risk_level == "EVACUATE")
                )
                db.add(new_alert)

    # Audit log
    audit = AuditLog(
        event_type="Report Verified",
        zone_name=report.location_name,
        details=f"Report {report.report_code} marked as '{verify_in.status}' by {verify_in.verified_by}.",
        action_by=verify_in.verified_by
    )
    db.add(audit)

    db.commit()
    db.refresh(report)
    return {"message": "Report status updated", "report": report}
