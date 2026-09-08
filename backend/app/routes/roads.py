from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
from typing import List
import random

from app.database import get_db
from app.models import RoadStatus, AuditLog
from app.schemas import (
    RoadStatusRequest, 
    RoadStatusResponse, 
    RoadBlockRequest, 
    RoadClearRequest
)

router = APIRouter(prefix="/api/roads", tags=["Roads"])

@router.post("", response_model=RoadStatusResponse)
def create_road(req: RoadStatusRequest, db: Session = Depends(get_db)):
    """Create a new road entry"""
    existing = db.query(RoadStatus).filter(RoadStatus.road_id == req.road_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Road with this ID already exists")
    
    new_road = RoadStatus(
        road_id=req.road_id,
        road_name=req.road_name,
        start_location=req.start_location,
        end_location=req.end_location,
        district=req.district,
        status=req.status,
        blockage_reason=req.blockage_reason,
        latitude=req.latitude,
        longitude=req.longitude,
        risk_score=req.risk_score or 0.0,
        alternative_route_available=True
    )
    
    db.add(new_road)
    
    log_entry = AuditLog(
        event_type="Road Created",
        zone_name=req.district,
        details=f"New road registered: {req.road_name} ({req.road_id}). Status: {req.status}.",
        action_by="TerraGuard System"
    )
    db.add(log_entry)
    
    db.commit()
    db.refresh(new_road)
    return new_road

@router.get("/blocked", response_model=List[RoadStatusResponse])
def get_blocked_roads(db: Session = Depends(get_db)):
    """Get all blocked roads"""
    return db.query(RoadStatus).filter(RoadStatus.status == "BLOCKED").all()

@router.get("/district/{district}", response_model=List[RoadStatusResponse])
def get_roads_by_district(district: str, db: Session = Depends(get_db)):
    """Get all roads in a specific district"""
    return db.query(RoadStatus).filter(RoadStatus.district == district).all()

@router.get("", response_model=List[RoadStatusResponse])
def get_all_roads(db: Session = Depends(get_db)):
    """Get all roads"""
    return db.query(RoadStatus).all()

@router.get("/{road_id}", response_model=RoadStatusResponse)
def get_road(road_id: str, db: Session = Depends(get_db)):
    """Get a specific road by ID"""
    road = db.query(RoadStatus).filter(RoadStatus.road_id == road_id).first()
    if not road:
        raise HTTPException(status_code=404, detail="Road not found")
    return road

@router.post("/block", response_model=RoadStatusResponse)
def block_road(req: RoadBlockRequest, db: Session = Depends(get_db)):
    """Block a road due to landslide or other reason"""
    road = db.query(RoadStatus).filter(RoadStatus.road_id == req.road_id).first()
    if not road:
        raise HTTPException(status_code=404, detail="Road not found")
    
    if road.status == "BLOCKED":
        raise HTTPException(status_code=400, detail="Road is already blocked")
    
    road.status = "BLOCKED"
    road.blockage_reason = req.blockage_reason
    road.latitude = req.latitude or road.latitude
    road.longitude = req.longitude or road.longitude
    road.risk_score = req.risk_score or road.risk_score
    road.blocked_at = datetime.utcnow()
    road.blocked_by = "TG-ADM-DEMO"  # In production, use actual admin user code
    road.affected_citizens_count = random.randint(50, 500)  # Simulated count
    road.last_updated = datetime.utcnow()
    
    log_entry = AuditLog(
        event_type="Road Blocked",
        zone_name=road.district,
        details=f"Road blocked: {road.road_name} ({road.road_id}). Reason: {req.blockage_reason}. Affected citizens: {road.affected_citizens_count}.",
        action_by="TerraGuard System"
    )
    db.add(log_entry)
    
    db.commit()
    db.refresh(road)
    return road

@router.post("/clear", response_model=RoadStatusResponse)
def clear_road(req: RoadClearRequest, db: Session = Depends(get_db)):
    """Clear a blocked road"""
    road = db.query(RoadStatus).filter(RoadStatus.road_id == req.road_id).first()
    if not road:
        raise HTTPException(status_code=404, detail="Road not found")
    
    if road.status == "OPEN":
        raise HTTPException(status_code=400, detail="Road is already open")
    
    road.status = "OPEN"
    road.blockage_reason = None
    road.cleared_at = datetime.utcnow()
    road.cleared_by = "TG-ADM-DEMO"  # In production, use actual admin user code
    road.risk_score = 0.0
    road.last_updated = datetime.utcnow()
    
    log_entry = AuditLog(
        event_type="Road Cleared",
        zone_name=road.district,
        details=f"Road cleared: {road.road_name} ({road.road_id}). Regular route restored for {road.affected_citizens_count} citizens.",
        action_by="TerraGuard System"
    )
    db.add(log_entry)
    
    db.commit()
    db.refresh(road)
    return road

@router.delete("/roads/{road_id}")
def delete_road(road_id: str, db: Session = Depends(get_db)):
    """Delete a road"""
    road = db.query(RoadStatus).filter(RoadStatus.road_id == road_id).first()
    if not road:
        raise HTTPException(status_code=404, detail="Road not found")
    
    db.delete(road)
    db.commit()
    return {"message": "Road deleted successfully"}
