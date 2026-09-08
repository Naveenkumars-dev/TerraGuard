from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class RiskCalculationInput(BaseModel):
    rainfall: float
    soilMoisture: float
    slope: float
    historicalRisk: float
    satelliteChange: float
    fieldReports: int = 0

class FactorBreakdown(BaseModel):
    name: str
    value: float
    impact: str # HIGH, MEDIUM, LOW

class RiskCalculationOutput(BaseModel):
    riskScore: float
    riskLevel: str # SAFE, WATCH, WARNING, EVACUATE
    confidence: float
    factors: List[FactorBreakdown]
    recommendation: str
    assessment: str

class ZoneBase(BaseModel):
    name: str
    district: str
    state: str
    latitude: float
    longitude: float
    rainfall: float
    soil_moisture: float
    slope: float
    historical_risk: float
    satellite_change: float
    field_reports_count: int
    population_affected: int
    roads_affected: int

class ZoneResponse(ZoneBase):
    id: int
    risk_score: float
    risk_level: str
    last_updated: datetime
    recommended_action: str

    class Config:
        from_attributes = True

class ReportCreate(BaseModel):
    reporter_type: str # Citizen, Field Official
    district: str
    location_name: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    issue_type: str # Crack, Slope movement, Rockfall, Road blockage, Water seepage
    severity: str   # Low, Medium, High, Critical
    description: str
    photo_url: Optional[str] = None
    zone_id: Optional[int] = None

class ReportResponse(ReportCreate):
    id: int
    report_code: str
    timestamp: datetime
    status: str
    verified_by: Optional[str] = None

    class Config:
        from_attributes = True

class ReportVerify(BaseModel):
    status: str # Verified, False Alarm, Escalated
    verified_by: str = "Admin User"

class AlertResponse(BaseModel):
    id: int
    alert_code: str
    zone_id: int
    zone_name: str
    district: str
    risk_score: float
    alert_level: str
    trigger_reason: str
    timestamp: datetime
    recipients: str
    status: str
    acknowledged: bool
    sms_sent: bool
    ivr_activated: bool

    class Config:
        from_attributes = True

class AuditLogResponse(BaseModel):
    id: int
    timestamp: datetime
    event_type: str
    zone_name: Optional[str]
    details: str
    action_by: str

    class Config:
        from_attributes = True

class ThresholdConfigUpdate(BaseModel):
    safe_max: float = 29.0
    watch_max: float = 59.0
    warning_max: float = 79.0
    evacuate_max: float = 100.0
    monitored_district: str = "All Districts"

class CitizenRegisterRequest(BaseModel):
    full_name: str
    phone: str
    gov_id_masked: Optional[str] = "Aadhaar XXXX-XXXX-4819"
    registered_district: str
    latitude: Optional[float] = 25.5788
    longitude: Optional[float] = 91.8933
    vulnerability_profile: Optional[str] = "Normal"
    emergency_contact: str

class CitizenResponse(BaseModel):
    id: int
    user_code: str
    full_name: str
    phone: str
    gov_id_masked: str
    identity_verified: bool
    registered_district: str
    latitude: Optional[float]
    longitude: Optional[float]
    vulnerability_profile: str
    emergency_contact: str
    alarm_enabled: bool
    registered_at: datetime
    role: str
    otp_verified: bool
    is_active: bool

    class Config:
        from_attributes = True

class EmergencyAlarmTriggerRequest(BaseModel):
    zone_id: Optional[int] = None
    district: str
    risk_score: float
    trigger_message: str

class ResourceAllocationResponse(BaseModel):
    id: int
    allocation_code: str
    incident_name: str
    district: str
    people_at_risk: int
    severity_level: str
    vulnerability_score: float
    time_criticality_minutes: int
    accessibility_score: float
    priority_score: float
    assigned_team: str
    assigned_vehicle: str
    rationale: str
    status: str

    class Config:
        from_attributes = True

class RoadDiversionResponse(BaseModel):
    id: int
    route_name: str
    district: str
    origin: str
    destination: str
    status: str
    landslide_risk_score: float
    additional_minutes: int
    is_recommended: bool
    blockage_reason: Optional[str]

    class Config:
        from_attributes = True

class ShelterResponse(BaseModel):
    id: int
    name: str
    district: str
    total_capacity: int
    current_occupancy: int
    distance_km: float
    route_status: str
    allocation_confidence: float
    water_pct: int
    food_pct: int
    medical_pct: int
    blankets_pct: int

    class Config:
        from_attributes = True

class CitizenStatusUpdateRequest(BaseModel):
    user_code: str
    status: str # SAFE, NEED_HELP
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class EmergencyStatusSummaryResponse(BaseModel):
    district: str
    safe_count: int
    need_help_count: int
    not_responded_count: int
    total_citizens: int

class MultiSourceBlockageResponse(BaseModel):
    id: int
    location: str
    district: str
    confidence_score: float
    sources: List[str]
    status: str

class RFGatewaySyncResponse(BaseModel):
    internet_online: bool
    rf_link_connected: bool
    messages_queued: int
    emergency_alerts_active: int
    last_sync: str
    mode: str

class RoadStatusRequest(BaseModel):
    road_id: str
    road_name: str
    start_location: str
    end_location: str
    district: str
    status: str  # OPEN, BLOCKED
    blockage_reason: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    risk_score: Optional[float] = 0.0

class RoadStatusResponse(BaseModel):
    id: int
    road_id: str
    road_name: str
    start_location: str
    end_location: str
    district: str
    status: str
    blockage_reason: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    risk_score: float
    blocked_at: Optional[datetime]
    cleared_at: Optional[datetime]
    blocked_by: Optional[str]
    cleared_by: Optional[str]
    affected_citizens_count: int
    alternative_route_available: bool
    last_updated: datetime

    class Config:
        from_attributes = True

class RoadBlockRequest(BaseModel):
    road_id: str
    blockage_reason: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    risk_score: Optional[float] = 0.0

class RoadClearRequest(BaseModel):
    road_id: str

class AdminRegisterRequest(BaseModel):
    full_name: str
    official_email: str
    phone: str
    gov_id_number: str
    gov_id_type: str
    department: str
    designation: str
    district: str

class AdminResponse(BaseModel):
    id: int
    user_code: str
    full_name: str
    official_email: str
    phone: str
    gov_id_number: str
    gov_id_type: str
    department: str
    designation: str
    district: str
    identity_verified: bool
    authority_approved: bool
    registered_at: datetime
    is_active: bool

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    phone: str
    role: str # CITIZEN, ADMIN

class LoginResponse(BaseModel):
    success: bool
    user_code: str
    full_name: str
    role: str
    verified: bool
    message: str


