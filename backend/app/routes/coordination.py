from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import ResourceAllocation, RoadDiversion, Zone, Shelter, RoadBlockageMultiSource
import json

router = APIRouter(prefix="/api/coordination", tags=["AI Emergency Coordination & Routing"])

@router.get("/shelters/{district}")
def get_shelters(district: str, db: Session = Depends(get_db)):
    shelters = db.query(Shelter).filter(Shelter.district == district).all()
    if not shelters:
        default_shelters = [
            Shelter(
                name="Government Higher Secondary School",
                district=district,
                total_capacity=100,
                current_occupancy=87,
                distance_km=2.1,
                route_status="Safe Corridor (Route C)",
                allocation_confidence=96.0,
                water_pct=87,
                food_pct=68,
                medical_pct=94,
                blankets_pct=51
            ),
            Shelter(
                name="Shillong Community Disaster Relief Centre",
                district=district,
                total_capacity=500,
                current_occupancy=120,
                distance_km=4.8,
                route_status="Safe Corridor",
                allocation_confidence=92.5,
                water_pct=95,
                food_pct=85,
                medical_pct=90,
                blankets_pct=80
            ),
            Shelter(
                name="Pine Ridge Multi-Purpose Hall",
                district=district,
                total_capacity=300,
                current_occupancy=290,
                distance_km=1.4,
                route_status="High Risk Route (Bypass)",
                allocation_confidence=45.0,
                water_pct=30,
                food_pct=40,
                medical_pct=50,
                blankets_pct=25
            )
        ]
        for s in default_shelters:
            db.add(s)
        db.commit()
        shelters = db.query(Shelter).filter(Shelter.district == district).all()

    return shelters

@router.get("/multi-source-blockages/{district}")
def get_multi_source_blockages(district: str, db: Session = Depends(get_db)):
    blockages = db.query(RoadBlockageMultiSource).filter(RoadBlockageMultiSource.district == district).all()
    if not blockages:
        b1 = RoadBlockageMultiSource(
            location="NH-6 Highway (KM 34 Corridor)",
            district=district,
            confidence_score=94.0,
            sources_json=json.dumps(["Camera / CCTV AI Vision", "Citizen Field Distress Report", "Weather & 85mm Rainfall Telemetry", "Road IoT Strain Sensors"]),
            status="Verified Blocked"
        )
        db.add(b1)
        db.commit()
        blockages = db.query(RoadBlockageMultiSource).filter(RoadBlockageMultiSource.district == district).all()

    result = []
    for b in blockages:
        result.append({
            "id": b.id,
            "location": b.location,
            "district": b.district,
            "confidence_score": b.confidence_score,
            "sources": json.loads(b.sources_json) if b.sources_json else [],
            "status": b.status
        })
    return result

@router.get("/resource-allocation")
def get_resource_allocations(db: Session = Depends(get_db)):

    allocations = db.query(ResourceAllocation).all()
    if not allocations:
        # Seed dynamic initial dataset for demonstration
        default_allocations = [
            ResourceAllocation(
                allocation_code="TG-RES-101",
                incident_name="St. Mary's School Complex (87 Trapped)",
                district="East Khasi Hills",
                people_at_risk=87,
                severity_level="Critical (94/100)",
                vulnerability_score=9.2, # Children & Elderly high weight
                time_criticality_minutes=24,
                accessibility_score=0.35, # Difficult single road
                priority_score=96.4,
                assigned_team="NDRF Rescue Battalion 2",
                assigned_vehicle="Rapid Ambulance Unit 3",
                rationale="Priority #1 assigned due to 87 trapped individuals (23% elderly, 11 children), critical landslide probability (94.0), and a narrow 24-minute rescue window before secondary slope collapse.",
                status="Dispatched"
            ),
            ResourceAllocation(
                allocation_code="TG-RES-102",
                incident_name="Upper Cherrapunji Village Settlement",
                district="East Khasi Hills",
                people_at_risk=43,
                severity_level="High (81/100)",
                vulnerability_score=8.5,
                time_criticality_minutes=45,
                accessibility_score=0.60,
                priority_score=78.1,
                assigned_team="SDRF Team 1",
                assigned_vehicle="Heavy Excavator Unit 1",
                rationale="Priority #2 assigned due to 43 residents with 12 elderly individuals. Moderate accessibility allows parallel deployment of heavy clearance machinery.",
                status="En Route"
            ),
            ResourceAllocation(
                allocation_code="TG-RES-103",
                incident_name="Highway Checkpoint 4 Transit Camp",
                district="East Khasi Hills",
                people_at_risk=14,
                severity_level="Moderate (58/100)",
                vulnerability_score=4.0,
                time_criticality_minutes=90,
                accessibility_score=0.90,
                priority_score=42.5,
                assigned_team="Civil Defense Mobile Patrol",
                assigned_vehicle="Utility Support Truck 2",
                rationale="Priority #3 assigned. Low immediate vulnerability, clear double-lane access route, stable temporary shelter nearby.",
                status="Standby"
            )
        ]
        for a in default_allocations:
            db.add(a)
        db.commit()
        allocations = db.query(ResourceAllocation).all()
        
    return allocations

@router.get("/routes/{district}")
def get_district_routes(district: str, db: Session = Depends(get_db)):
    routes = db.query(RoadDiversion).filter(RoadDiversion.district == district).all()
    if not routes:
        # Seed realistic road network alternatives for North East India
        default_routes = [
            RoadDiversion(
                route_name="Route A (NH-6 Highway)",
                district=district,
                origin="Shillong Central",
                destination="Guwahati Corridor / Evacuation Hub",
                status="BLOCKED",
                landslide_risk_score=88.5,
                additional_minutes=0,
                is_recommended=False,
                blockage_reason="Active landslide debris & tension cracks at KM 34"
            ),
            RoadDiversion(
                route_name="Route B (Old Hills Bypass)",
                district=district,
                origin="Shillong Central",
                destination="Guwahati Corridor / Evacuation Hub",
                status="HIGH_RISK",
                landslide_risk_score=62.0,
                additional_minutes=14,
                is_recommended=False,
                blockage_reason="Water seepage & high slope movement warning"
            ),
            RoadDiversion(
                route_name="Route C (Eastern Ridge Safe Corridor)",
                district=district,
                origin="Shillong Central",
                destination="Guwahati Corridor / Evacuation Hub",
                status="SAFE",
                landslide_risk_score=18.2,
                additional_minutes=11,
                is_recommended=True,
                blockage_reason=None
            )
        ]
        for r in default_routes:
            db.add(r)
        db.commit()
        routes = db.query(RoadDiversion).filter(RoadDiversion.district == district).all()

    return {
        "district": district,
        "recommended_route": next((r for r in routes if r.is_recommended), None),
        "all_routes": routes,
        "analysis_summary": "Route C is selected over Route A (Blocked 88.5% risk) despite +11 min travel time because it minimizes disaster hazard exposure."
    }
