from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import get_db
from app.models import AuditLog, SystemConfig, RFGatewayConfig
from app.schemas import AuditLogResponse, ThresholdConfigUpdate
from typing import List

router = APIRouter(prefix="/api/system", tags=["System Status & Configuration"])

@router.get("/rf-gateway")
def get_rf_gateway_status(db: Session = Depends(get_db)):
    cfg = db.query(RFGatewayConfig).first()
    if not cfg:
        cfg = RFGatewayConfig(
            internet_online=True,
            rf_link_connected=True,
            messages_queued=7,
            emergency_alerts_active=3,
            last_sync="22:41"
        )
        db.add(cfg)
        db.commit()
        db.refresh(cfg)

    return {
        "internet_online": cfg.internet_online,
        "rf_link_connected": cfg.rf_link_connected,
        "messages_queued": cfg.messages_queued,
        "emergency_alerts_active": cfg.emergency_alerts_active,
        "last_sync": cfg.last_sync,
        "mode": "ONLINE" if cfg.internet_online else "OFFLINE EMERGENCY MODE (RF Radio Gateway Active)"
    }

@router.post("/rf-gateway/toggle")
def toggle_rf_gateway(db: Session = Depends(get_db)):
    cfg = db.query(RFGatewayConfig).first()
    if not cfg:
        cfg = RFGatewayConfig(internet_online=False, rf_link_connected=True, messages_queued=7, emergency_alerts_active=3)
        db.add(cfg)
    else:
        cfg.internet_online = not cfg.internet_online
        if not cfg.internet_online:
            cfg.messages_queued += 1

    audit = AuditLog(
        event_type="NETWORK FAILOVER TOGGLE",
        zone_name="System Wide",
        details=f"Cellular Internet status toggled to {'ONLINE' if cfg.internet_online else 'OFFLINE EMERGENCY MODE (RF Radio Link Active)'}",
        action_by="TerraGuard Network Manager"
    )
    db.add(audit)
    db.commit()
    db.refresh(cfg)

    return {
        "internet_online": cfg.internet_online,
        "rf_link_connected": cfg.rf_link_connected,
        "messages_queued": cfg.messages_queued,
        "emergency_alerts_active": cfg.emergency_alerts_active,
        "last_sync": cfg.last_sync,
        "mode": "ONLINE" if cfg.internet_online else "OFFLINE EMERGENCY MODE (RF Radio Gateway Active)"
    }

@router.get("/status")
def get_system_status(db: Session = Depends(get_db)):
    config = db.query(SystemConfig).first()
    return {
        "status": "OPERATIONAL",
        "timestamp": datetime.utcnow().isoformat(),
        "lowBandwidthMode": config.low_bandwidth_mode if config else False,
        "monitoredDistrict": config.monitored_district if config else "All Districts",
        "dataSources": [
            {
                "name": "IMD Rainfall API",
                "type": "Meteorological Feed",
                "status": "Connected",
                "latency": "42ms",
                "lastUpdate": "2 minutes ago",
                "isSimulated": True
            },
            {
                "name": "ISRO Sentinel-2 Satellite Change Indicator",
                "type": "EO Remote Sensing",
                "status": "Connected",
                "latency": "180ms",
                "lastUpdate": "15 minutes ago",
                "isSimulated": True
            },
            {
                "name": "GSI High-Resolution DEM / Slope Terrain",
                "type": "Geospatial GIS Data",
                "status": "Available",
                "latency": "12ms",
                "lastUpdate": "Cached / Static DEM",
                "isSimulated": False
            },
            {
                "name": "State Telemetric Soil Moisture Sensors",
                "type": "IoT Hardware Grid",
                "status": "18/24 Sensors Online",
                "latency": "110ms",
                "lastUpdate": "1 minute ago",
                "isSimulated": True
            },
            {
                "name": "Historical Landslide Archive (GSI/MDoNER)",
                "type": "Historical Database",
                "status": "Available",
                "latency": "5ms",
                "lastUpdate": "Connected",
                "isSimulated": False
            }
        ]
    }

@router.get("/logs", response_model=List[AuditLogResponse])
def get_audit_logs(db: Session = Depends(get_db)):
    return db.query(AuditLog).order_by(AuditLog.timestamp.desc()).all()

@router.get("/config")
def get_system_config(db: Session = Depends(get_db)):
    config = db.query(SystemConfig).first()
    if not config:
        config = SystemConfig()
        db.add(config)
        db.commit()
        db.refresh(config)
    return config

@router.post("/config")
def update_system_config(config_in: ThresholdConfigUpdate, db: Session = Depends(get_db)):
    config = db.query(SystemConfig).first()
    if not config:
        config = SystemConfig()
        db.add(config)
    
    config.safe_max = config_in.safe_max
    config.watch_max = config_in.watch_max
    config.warning_max = config_in.warning_max
    config.evacuate_max = config_in.evacuate_max
    config.monitored_district = config_in.monitored_district

    # Audit log
    audit = AuditLog(
        event_type="Threshold Configured",
        zone_name=None,
        details=f"Risk thresholds updated: SAFE <= {config.safe_max}, WATCH <= {config.watch_max}, WARNING <= {config.warning_max}, EVACUATE <= {config.evacuate_max}. District filter: {config.monitored_district}.",
        action_by="System Administrator"
    )
    db.add(audit)

    db.commit()
    return {"message": "System configuration updated successfully", "config": config}
