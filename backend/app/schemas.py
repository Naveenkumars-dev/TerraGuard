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
