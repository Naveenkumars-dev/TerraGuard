from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import get_db
from app.models import Zone, Alert, Report, AuditLog
from app.risk_engine import calculate_landslide_risk
from seed_data import seed_database

router = APIRouter(prefix="/api/demo", tags=["Demo Mode Workflow"])

@router.post("/reset")
def reset_demo_data():
    seed_database()
    return {"message": "Demo data reset to initial baseline baseline state."}

@router.post("/step/{step_id}")
def execute_demo_step(step_id: int, db: Session = Depends(get_db)):
    zone = db.query(Zone).filter(Zone.name.like("%East Khasi%")).first() or db.query(Zone).first()
    
    response_payload = {
        "stepId": step_id,
        "title": "",
        "description": "",
        "zoneName": zone.name if zone else "East Khasi Hills",
        "currentRiskScore": zone.risk_score if zone else 74.0,
        "riskLevel": zone.risk_level if zone else "WARNING"
    }

    if step_id == 1:
        response_payload["title"] = "Step 1: Baseline Monitoring - East Khasi Hills"
        response_payload["description"] = "Monitoring baseline parameters in East Khasi Hills. Current rainfall: 112mm, Soil saturation: 84%."
    
    elif step_id == 2:
        zone.rainfall = 145.0
        zone.soil_moisture = 89.0
        calc = calculate_landslide_risk(zone.rainfall, zone.soil_moisture, zone.slope, zone.historical_risk, zone.satellite_change, zone.field_reports_count)
        zone.risk_score = calc["riskScore"]
        zone.risk_level = calc["riskLevel"]
        db.commit()

        response_payload["title"] = "Step 2: Cloudburst Surge Detected"
        response_payload["description"] = "Rainfall increased to 145mm/24h. Soil moisture reached 89% saturation."
    
    elif step_id == 3:
        report = Report(
            report_code="TG-RPT-DEMO",
            reporter_type="Field Official",
            district="East Khasi Hills",
            location_name="Nongpriang Slope Cut, Km 14",
            latitude=zone.latitude + 0.005,
            longitude=zone.longitude + 0.005,
            issue_type="Crack",
            severity="Critical",
            description="Active 6-inch tension crack propagating along highway embankment.",
            photo_url="https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.utcnow(),
            status="Pending Verification",
            zone_id=zone.id
        )
        db.add(report)
        db.commit()

        response_payload["title"] = "Step 3: Field Official Submits Slope Distress Report"
        response_payload["description"] = "Field Official submitted tension crack report TG-RPT-DEMO with photos and GPS."

    elif step_id == 4:
        rpt = db.query(Report).filter(Report.report_code == "TG-RPT-DEMO").first()
        if rpt:
            rpt.status = "Verified"
            rpt.verified_by = "District Admin"
        
        zone.field_reports_count += 1
        calc = calculate_landslide_risk(zone.rainfall, zone.soil_moisture, zone.slope, zone.historical_risk, zone.satellite_change, zone.field_reports_count)
        zone.risk_score = calc["riskScore"]
        zone.risk_level = calc["riskLevel"]

        db.commit()

        response_payload["title"] = "Step 4: Citizen-in-the-Loop Report Verification"
        response_payload["description"] = "District Admin verified distress report. AI risk engine integrated verification into score."

    elif step_id == 5:
        alert = Alert(
            alert_code="TG-ALT-DEMO",
            zone_id=zone.id,
            zone_name=zone.name,
            district=zone.district,
            risk_score=zone.risk_score,
            alert_level="EVACUATE",
            trigger_reason="Extreme rainfall (145mm) + soil saturation (89%) + verified critical slope crack",
            timestamp=datetime.utcnow(),
            recipients="State Disaster Authority, District Collector, Local Residents",
            status="Active",
            acknowledged=False,
            sms_sent=True,
            ivr_activated=True
        )
        db.add(alert)
        
        audit = AuditLog(
            event_type="EVACUATE Alert Generated",
            zone_name=zone.name,
            details=f"EVACUATION ALERT TG-ALT-DEMO dispatched for {zone.name}. Risk score: {zone.risk_score}.",
            action_by="AI Risk Engine"
        )
        db.add(audit)
        db.commit()

        response_payload["title"] = "Step 5: EVACUATION Alert & SMS Broadcast"
        response_payload["description"] = "Risk crossed threshold to EVACUATE. SMS broadcast and IVR fallback dispatched automatically."

    response_payload["currentRiskScore"] = zone.risk_score
    response_payload["riskLevel"] = zone.risk_level
    return response_payload
