from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Zone, Alert, Report

router = APIRouter(prefix="/api/analytics", tags=["Analytics"])

@router.get("")
def get_analytics_data(db: Session = Depends(get_db)):
    zones = db.query(Zone).all()
    alerts = db.query(Alert).all()
    reports = db.query(Report).all()

    # 1. Monthly Incidents (historical trend for NER)
    monthly_incidents = [
        {"month": "Jan", "incidents": 2, "rainfall": 15},
        {"month": "Feb", "incidents": 3, "rainfall": 22},
        {"month": "Mar", "incidents": 5, "rainfall": 45},
        {"month": "Apr", "incidents": 12, "rainfall": 110},
        {"month": "May", "incidents": 24, "rainfall": 210},
        {"month": "Jun", "incidents": 42, "rainfall": 380},
        {"month": "Jul", "incidents": 58, "rainfall": 460},
        {"month": "Aug", "incidents": 51, "rainfall": 420},
        {"month": "Sep", "incidents": 36, "rainfall": 310},
        {"month": "Oct", "incidents": 15, "rainfall": 140},
        {"month": "Nov", "incidents": 4, "rainfall": 35},
        {"month": "Dec", "incidents": 1, "rainfall": 12},
    ]

    # 2. Rainfall vs Risk Score per zone
    rainfall_vs_risk = [
        {
            "zone": z.name,
            "district": z.district,
            "rainfall": z.rainfall,
            "riskScore": z.risk_score,
            "soilMoisture": z.soil_moisture
        }
        for z in zones
    ]

    # 3. Zones by District
    district_counts = {}
    for z in zones:
        district_counts[z.district] = district_counts.get(z.district, 0) + 1
    
    zones_by_district = [{"district": k, "count": v} for k, v in district_counts.items()]

    # 4. Alerts by Severity
    evacuate_count = sum(1 for a in alerts if a.alert_level == "EVACUATE")
    warning_count = sum(1 for a in alerts if a.alert_level == "WARNING")
    watch_count = sum(1 for a in alerts if a.alert_level == "WATCH")
    safe_count = sum(1 for z in zones if z.risk_level == "SAFE")

    alerts_by_severity = [
        {"level": "EVACUATE", "count": evacuate_count, "color": "#EF4444"},
        {"level": "WARNING", "count": warning_count, "color": "#F97316"},
        {"level": "WATCH", "count": watch_count, "color": "#EAB308"},
        {"level": "SAFE", "count": safe_count, "color": "#22C55E"}
    ]

    # 5. Verified vs False Reports
    verified_reports = sum(1 for r in reports if r.status in ["Verified", "Escalated"])
    pending_reports = sum(1 for r in reports if r.status == "Pending Verification")
    false_reports = sum(1 for r in reports if r.status == "False Alarm")

    report_verification_stats = [
        {"name": "Verified", "value": verified_reports, "color": "#22C55E"},
        {"name": "Pending", "value": pending_reports, "color": "#EAB308"},
        {"name": "False Alarm", "value": false_reports, "color": "#6B7280"}
    ]

    return {
        "monthlyIncidents": monthly_incidents,
        "rainfallVsRisk": rainfall_vs_risk,
        "zonesByDistrict": zones_by_district,
        "alertsBySeverity": alerts_by_severity,
        "reportVerificationStats": report_verification_stats,
        "totalZones": len(zones),
        "totalAlerts": len(alerts),
        "totalReports": len(reports)
    }
