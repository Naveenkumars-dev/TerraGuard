from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models import Zone
from app.schemas import ZoneResponse

router = APIRouter(prefix="/api/zones", tags=["Zones"])

@router.get("", response_model=List[ZoneResponse])
def get_zones(district: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Zone)
    if district and district != "All Districts":
        query = query.filter(Zone.district == district)
    return query.all()

@router.get("/{zone_id}", response_model=ZoneResponse)
def get_zone_by_id(zone_id: int, db: Session = Depends(get_db)):
    zone = db.query(Zone).filter(Zone.id == zone_id).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")
    return zone
