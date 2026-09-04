from fastapi import APIRouter
from app.schemas import RiskCalculationInput, RiskCalculationOutput
from app.risk_engine import calculate_landslide_risk

router = APIRouter(prefix="/api/risk", tags=["Risk Engine"])

@router.post("/calculate", response_model=RiskCalculationOutput)
def calculate_risk(input_data: RiskCalculationInput):
    result = calculate_landslide_risk(
        rainfall=input_data.rainfall,
        soil_moisture=input_data.soilMoisture,
        slope=input_data.slope,
        historical_risk=input_data.historicalRisk,
        satellite_change=input_data.satelliteChange,
        field_reports=input_data.fieldReports
    )
    return result
