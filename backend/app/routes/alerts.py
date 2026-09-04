from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import random

from app.database import get_db
from app.models import Alert, Zone, AuditLog
from app.schemas import AlertResponse
from app.risk_engine import calculate_landslide_risk

router = APIRouter(prefix="/api/alerts", tags=["Alerts"])

@router.get("", response_model=List[AlertResponse])
def get_alerts(db: Session = Depends(get_db)):
    return db.query(Alert).order_by(Alert.timestamp.desc()).all()

@router.post("/{alert_id}/acknowledge")
def acknowledge_alert(alert_id: int, db: Session = Depends(get_db)):
    alert = db.query(Alert).filter(Alert.id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    
    alert.acknowledged = True
    alert.status = "Acknowledged"
    
    # Audit log
    audit = AuditLog(
        event_type="Alert Acknowledged",
        zone_name=alert.zone_name,
        details=f"Alert {alert.alert_code} acknowledged by user.",
        action_by="District Admin"
    )
    db.add(audit)
    db.commit()
    db.refresh(alert)
    return {"message": "Alert acknowledged successfully", "alert": alert}

@router.post("/simulate")
def simulate_heavy_rainfall(zone_id: Optional[int] = None, db: Session = Depends(get_db)):
    """
    Simulates a heavy rainfall event for demonstration:
    1. Increases rainfall & soil moisture
    2. Recalculates risk score & status
    3. Triggers alert and logs audit event
    """
    if zone_id:
        zone = db.query(Zone).filter(Zone.id == zone_id).first()
    else:
        # Default to East Khasi Hills or highest risk zone
        zone = db.query(Zone).filter(Zone.name.like("%Khasi%")).first() or db.query(Zone).first()

    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found for simulation")

    prev_score = zone.risk_score
    prev_level = zone.risk_level

    # Simulate sudden monsoon cloudburst / heavy rain
    zone.rainfall = min(180.0, round(zone.rainfall + random.uniform(30.0, 45.0), 1))
    zone.soil_moisture = min(98.0, round(zone.soil_moisture + random.uniform(12.0, 18.0), 1))
    
    # Recalculate
    calc = calculate_landslide_risk(
        rainfall=zone.rainfall,
        soil_moisture=zone.soil_moisture,
        slope=zone.slope,
        historical_risk=zone.historical_risk,
        satellite_change=zone.satellite_change,
        field_reports=zone.field_reports_count
    )

    zone.risk_score = calc["riskScore"]
    zone.risk_level = calc["riskLevel"]
    zone.recommended_action = calc["recommendation"]
    zone.last_updated = datetime.utcnow()

    # Generate Alert Code
    new_code = f"TG-ALT-{random.randint(1050, 9999)}"
    
    trigger_msg = f"Heavy Rainfall Cloudburst ({zone.rainfall}mm) + High Soil Saturation ({zone.soil_moisture}%)"
    
    alert = Alert(
        alert_code=new_code,
        zone_id=zone.id,
        zone_name=zone.name,
        district=zone.district,
        risk_score=zone.risk_score,
        alert_level=zone.risk_level,
        trigger_reason=trigger_msg,
        timestamp=datetime.utcnow(),
        recipients="District Disaster Mgmt, Emergency Responders, Local Residents",
        status="Active",
        acknowledged=False,
        sms_sent=True,
        ivr_activated=(zone.risk_level == "EVACUATE")
    )
    db.add(alert)

    # Audit log entry
    audit = AuditLog(
        event_type="Rainfall Event Simulated",
        zone_name=zone.name,
        details=f"Heavy rainfall event simulated. Risk score escalated from {prev_score} ({prev_level}) to {zone.risk_score} ({zone.risk_level}). Alert {new_code} created.",
        action_by="Demo Event Simulator"
    )
    db.add(audit)

    db.commit()
    db.refresh(zone)
    db.refresh(alert)

    return {
        "message": "Rainfall simulation completed successfully",
        "zone": zone,
        "alert": alert,
        "previousScore": prev_score,
        "previousLevel": prev_level,
        "notification": {
            "title": f"RISK ESCALATION DETECTED - {zone.name}",
            "previousRisk": prev_score,
            "currentRisk": zone.risk_score,
            "status": zone.risk_level,
            "alertCode": new_code,
            "smsText": f"TERRAGUARD ALERT: {zone.risk_level} NOW. High landslide risk detected in {zone.district}. Follow local authority instructions immediately."
        }
    }
