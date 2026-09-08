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

class CitizenUser(Base):
    __tablename__ = "citizen_users"

    id = Column(Integer, primary_key=True, index=True)
    user_code = Column(String, unique=True, index=True) # e.g. TG-USR-9482
    full_name = Column(String)
    phone = Column(String, unique=True, index=True)
    gov_id_masked = Column(String) # e.g. Aadhaar XXXX-XXXX-1234
    identity_verified = Column(Boolean, default=True)
    registered_district = Column(String)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    vulnerability_profile = Column(String) # Normal, Elderly, Children, Disability, Medical Needs
    emergency_contact = Column(String)
    alarm_enabled = Column(Boolean, default=True)
    registered_at = Column(DateTime, default=datetime.utcnow)
    role = Column(String, default="CITIZEN") # CITIZEN, ADMIN
    otp_verified = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)

class ResourceAllocation(Base):
    __tablename__ = "resource_allocations"

    id = Column(Integer, primary_key=True, index=True)
    allocation_code = Column(String, unique=True, index=True) # e.g. TG-RES-101
    incident_name = Column(String)
    district = Column(String)
    people_at_risk = Column(Integer)
    severity_level = Column(String) # Critical, High, Moderate
    vulnerability_score = Column(Float)
    time_criticality_minutes = Column(Integer)
    accessibility_score = Column(Float) # 0-1 scale
    priority_score = Column(Float)
    assigned_team = Column(String) # e.g. NDRF Rescue Team 2
    assigned_vehicle = Column(String) # e.g. Ambulance 3
    rationale = Column(Text)
    status = Column(String, default="Dispatched") # Dispatched, En Route, Completed

class RoadDiversion(Base):
    __tablename__ = "road_diversions"

    id = Column(Integer, primary_key=True, index=True)
    route_name = Column(String) # e.g. Route A (NH-6), Route C (Shillong Bypass)
    district = Column(String)
    origin = Column(String)
    destination = Column(String)
    status = Column(String) # BLOCKED, HIGH_RISK, SAFE
    landslide_risk_score = Column(Float)
    additional_minutes = Column(Integer)
    is_recommended = Column(Boolean, default=False)
    blockage_reason = Column(String, nullable=True)

class Shelter(Base):
    __tablename__ = "shelters"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String) # e.g. Government Higher Secondary School
    district = Column(String)
    total_capacity = Column(Integer)
    current_occupancy = Column(Integer)
    distance_km = Column(Float)
    route_status = Column(String, default="Safe") # Safe, Moderate Risk, Blocked
    allocation_confidence = Column(Float, default=96.0)
    water_pct = Column(Integer, default=87)
    food_pct = Column(Integer, default=68)
    medical_pct = Column(Integer, default=94)
    blankets_pct = Column(Integer, default=51)

class EmergencyCitizenStatus(Base):
    __tablename__ = "emergency_citizen_statuses"

    id = Column(Integer, primary_key=True, index=True)
    user_code = Column(String, index=True)
    full_name = Column(String)
    district = Column(String)
    status = Column(String) # SAFE, NEED_HELP, NOT_RESPONDED
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class RoadBlockageMultiSource(Base):
    __tablename__ = "road_blockage_multisource"

    id = Column(Integer, primary_key=True, index=True)
    location = Column(String)
    district = Column(String)
    confidence_score = Column(Float) # e.g. 94%
    sources_json = Column(Text) # CCTV Camera, User Field Report, Weather & Rainfall Telemetry, Road IoT Sensors
    status = Column(String, default="Verified Blockage")

class RFGatewayConfig(Base):
    __tablename__ = "rf_gateway_config"

    id = Column(Integer, primary_key=True, index=True)
    internet_online = Column(Boolean, default=True)
    rf_link_connected = Column(Boolean, default=True)
    messages_queued = Column(Integer, default=7)
    emergency_alerts_active = Column(Integer, default=3)
    last_sync = Column(String, default="22:41")

class AdminUser(Base):
    __tablename__ = "admin_users"

    id = Column(Integer, primary_key=True, index=True)
    user_code = Column(String, unique=True, index=True) # e.g. TG-ADM-101
    full_name = Column(String)
    official_email = Column(String, unique=True, index=True)
    phone = Column(String, unique=True, index=True)
    gov_id_number = Column(String)
    gov_id_type = Column(String) # PAN, Employee ID, Government Service ID, Aadhaar
    department = Column(String)
    designation = Column(String)
    district = Column(String)
    identity_verified = Column(Boolean, default=True)
    authority_approved = Column(Boolean, default=True)
    registered_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)

class RoadStatus(Base):
    __tablename__ = "road_status"

    id = Column(Integer, primary_key=True, index=True)
    road_id = Column(String, unique=True, index=True) # e.g. RD-102
    road_name = Column(String, index=True)
    start_location = Column(String)
    end_location = Column(String)
    district = Column(String)
    status = Column(String, default="OPEN") # OPEN, BLOCKED
    blockage_reason = Column(String) # LANDSLIDE, FLOOD, MAINTENANCE
    latitude = Column(Float)
    longitude = Column(Float)
    risk_score = Column(Float, default=0.0)
    blocked_at = Column(DateTime, nullable=True)
    cleared_at = Column(DateTime, nullable=True)
    blocked_by = Column(String, nullable=True) # Admin user code
    cleared_by = Column(String, nullable=True) # Admin user code
    affected_citizens_count = Column(Integer, default=0)
    alternative_route_available = Column(Boolean, default=True)
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
