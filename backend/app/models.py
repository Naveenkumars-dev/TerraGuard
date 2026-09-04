from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text
from datetime import datetime
from app.database import Base

class Zone(Base):
    __tablename__ = "zones"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    district = Column(String, index=True)
    state = Column(String, index=True)
    latitude = Column(Float)
    longitude = Column(Float)
    
    # Environmental factors
    rainfall = Column(Float, default=0.0)         # in mm (24h)
    soil_moisture = Column(Float, default=0.0)    # % saturation
    slope = Column(Float, default=0.0)            # degrees
    historical_risk = Column(Float, default=0.0)  # 0-100 scale
    satellite_change = Column(Float, default=0.0) # 0-100 scale
    field_reports_count = Column(Integer, default=0)
    
    # Calculated risk outputs
    risk_score = Column(Float, default=0.0)       # 0-100 scale
    risk_level = Column(String, default="SAFE")   # SAFE, WATCH, WARNING, EVACUATE
    
    # Impact metrics
    population_affected = Column(Integer, default=0)
    roads_affected = Column(Integer, default=0)
    
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    recommended_action = Column(Text, default="Normal monitoring")

class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    alert_code = Column(String, unique=True, index=True) # e.g. TG-1024
    zone_id = Column(Integer)
    zone_name = Column(String)
    district = Column(String)
    risk_score = Column(Float)
    alert_level = Column(String) # WATCH, WARNING, EVACUATE
    trigger_reason = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)
    recipients = Column(String) # comma separated or JSON string
    status = Column(String, default="Active") # Active, Acknowledged, Resolved
    acknowledged = Column(Boolean, default=False)
    sms_sent = Column(Boolean, default=True)
    ivr_activated = Column(Boolean, default=False)

class Report(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    report_code = Column(String, unique=True, index=True) # e.g. TG-RPT-1042
    reporter_type = Column(String) # Citizen, Field Official
    district = Column(String)
    location_name = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    issue_type = Column(String) # Crack, Slope movement, Rockfall, Road blockage, Water seepage
    severity = Column(String)   # Low, Medium, High, Critical
    description = Column(Text)
    photo_url = Column(String, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    status = Column(String, default="Pending Verification") # Pending Verification, Verified, False Alarm, Escalated
    verified_by = Column(String, nullable=True)
    zone_id = Column(Integer, nullable=True)

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    event_type = Column(String) # Risk Update, Report Received, Report Verified, Alert Generated, Threshold Configured
    zone_name = Column(String, nullable=True)
    details = Column(Text)
    action_by = Column(String, default="System AI")

class SystemConfig(Base):
    __tablename__ = "system_config"

    id = Column(Integer, primary_key=True, index=True)
    safe_max = Column(Float, default=29.0)
    watch_max = Column(Float, default=59.0)
    warning_max = Column(Float, default=79.0)
    evacuate_max = Column(Float, default=100.0)
    monitored_district = Column(String, default="All Districts")
    low_bandwidth_mode = Column(Boolean, default=False)
