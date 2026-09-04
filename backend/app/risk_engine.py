from typing import Dict, Any, List, Tuple
from app.schemas import FactorBreakdown, RiskCalculationOutput

def calculate_landslide_risk(
    rainfall: float,
    soil_moisture: float,
    slope: float,
    historical_risk: float,
    satellite_change: float,
    field_reports: int = 0
) -> Dict[str, Any]:
    """
    Explainable AI-Inspired Weighted Landslide Risk Calculation Model.
    
    Weights:
    - Rainfall (24h mm): 30% (Normalized up to 150mm)
    - Soil Moisture (%): 20%
    - Slope (degrees): 20% (Normalized up to 50 deg)
    - Historical Risk Index (0-100): 15%
    - Satellite Change Indicator (0-100): 10%
    - Field/Citizen Reports: 5% (Normalized up to 5 reports)
    """
    
    # 1. Normalize environmental indicators to 0-100 scale
    norm_rainfall = min(100.0, (rainfall / 150.0) * 100.0)
    norm_soil = min(100.0, max(0.0, soil_moisture))
    norm_slope = min(100.0, (slope / 50.0) * 100.0)
    norm_hist = min(100.0, max(0.0, historical_risk))
    norm_sat = min(100.0, max(0.0, satellite_change))
    norm_reports = min(100.0, (field_reports / 5.0) * 100.0)

    # 2. Weighted score aggregation
    score = (
        (norm_rainfall * 0.30) +
        (norm_soil * 0.20) +
        (norm_slope * 0.20) +
        (norm_hist * 0.15) +
        (norm_sat * 0.10) +
        (norm_reports * 0.05)
    )

    risk_score = round(min(100.0, max(0.0, score)), 1)

    # 3. Determine Risk Level
    if risk_score >= 80.0:
        risk_level = "EVACUATE"
        recommendation = "Immediate evacuation of vulnerable populations along slopes. Restrict access to landslide-prone roads."
    elif risk_score >= 60.0:
        risk_level = "WARNING"
        recommendation = "Prepare emergency response units. Issue advisory to local authorities and monitor slopes closely."
    elif risk_score >= 30.0:
        risk_level = "WATCH"
        recommendation = "Increase monitoring frequency. Alert local field inspectors and check drainage infrastructure."
    else:
        risk_level = "SAFE"
        recommendation = "Normal routine monitoring. No immediate threat detected."

    # 4. Impact Factor Classification
    factors: List[FactorBreakdown] = []

    def get_impact(val: float) -> str:
        if val >= 70.0:
            return "HIGH"
        elif val >= 40.0:
            return "MEDIUM"
        else:
            return "LOW"

    factors.append(FactorBreakdown(
        name="Rainfall Intensity",
        value=round(rainfall, 1),
        impact=get_impact(norm_rainfall)
    ))
    factors.append(FactorBreakdown(
        name="Soil Saturation",
        value=round(soil_moisture, 1),
        impact=get_impact(norm_soil)
    ))
    factors.append(FactorBreakdown(
        name="Terrain Slope",
        value=round(slope, 1),
        impact=get_impact(norm_slope)
    ))
    factors.append(FactorBreakdown(
        name="Historical Risk Index",
        value=round(historical_risk, 1),
        impact=get_impact(norm_hist)
    ))
    factors.append(FactorBreakdown(
        name="Satellite Terrain Change",
        value=round(satellite_change, 1),
        impact=get_impact(norm_sat)
    ))
    if field_reports > 0:
        factors.append(FactorBreakdown(
            name="Field Distress Reports",
            value=float(field_reports),
            impact=get_impact(norm_reports)
        ))

    # 5. AI Narrative Assessment & Confidence
    confidence = round(min(96.0, 85.0 + (field_reports * 1.5) + (1.0 if rainfall > 50 else 0.5)), 1)
    
    high_impact_names = [f.name for f in factors if f.impact == "HIGH"]
    if high_impact_names:
        drivers = ", ".join(high_impact_names)
        assessment = f"Landslide probability is critically elevated due to high impact drivers: {drivers}."
    else:
        assessment = "Environmental parameters remain within stable operational limits with low landslide probability."

    return {
        "riskScore": risk_score,
        "riskLevel": risk_level,
        "confidence": confidence,
        "factors": [f.dict() for f in factors],
        "recommendation": recommendation,
        "assessment": assessment
    }
