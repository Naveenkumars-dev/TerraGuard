from app.database import SessionLocal, engine, Base
from app.models import Zone, Alert, Report, AuditLog, SystemConfig
from app.risk_engine import calculate_landslide_risk
from datetime import datetime, timedelta, timezone

def seed_database():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    # Clear existing data if any
    db.query(Zone).delete()
    db.query(Alert).delete()
    db.query(Report).delete()
    db.query(AuditLog).delete()
    db.query(SystemConfig).delete()
    db.commit()

    # Create default configuration
    config = SystemConfig(
        safe_max=29.0,
        watch_max=59.0,
        warning_max=79.0,
        evacuate_max=100.0,
        monitored_district="All Districts",
        low_bandwidth_mode=False
    )
    db.add(config)

    # 15 Realistic zones across NER (North Eastern Region of India)
    raw_zones = [
        {
            "name": "East Khasi Hills (Nongpriang)",
            "district": "East Khasi Hills",
            "state": "Meghalaya",
            "latitude": 25.3200,
            "longitude": 91.7000,
            "rainfall": 112.5,
            "soil_moisture": 84.0,
            "slope": 38.0,
            "historical_risk": 78.0,
            "satellite_change": 65.0,
            "field_reports_count": 3,
            "population_affected": 18420,
            "roads_affected": 14
        },
        {
            "name": "Gangtok Ridge North",
            "district": "East Sikkim",
            "state": "Sikkim",
            "latitude": 27.3389,
            "longitude": 88.6138,
            "rainfall": 94.0,
            "soil_moisture": 76.5,
            "slope": 42.0,
            "historical_risk": 70.0,
            "satellite_change": 58.0,
            "field_reports_count": 2,
            "population_affected": 12150,
            "roads_affected": 8
        },
        {
            "name": "Tawang Pass Sector 4",
            "district": "Tawang",
            "state": "Arunachal Pradesh",
            "latitude": 27.5861,
            "longitude": 91.8594,
            "rainfall": 48.0,
            "soil_moisture": 62.0,
            "slope": 35.0,
            "historical_risk": 64.0,
            "satellite_change": 40.0,
            "field_reports_count": 1,
            "population_affected": 6300,
            "roads_affected": 5
        },
        {
            "name": "Aizawl Slope Corridor",
            "district": "Aizawl",
            "state": "Mizoram",
            "latitude": 23.7271,
            "longitude": 92.7176,
            "rainfall": 82.0,
            "soil_moisture": 71.0,
            "slope": 36.0,
            "historical_risk": 72.0,
            "satellite_change": 51.0,
            "field_reports_count": 2,
            "population_affected": 15200,
            "roads_affected": 11
        },
        {
            "name": "Kohima Urban Slope",
            "district": "Kohima",
            "state": "Nagaland",
            "latitude": 25.6751,
            "longitude": 94.1086,
            "rainfall": 35.0,
            "soil_moisture": 52.0,
            "slope": 28.0,
            "historical_risk": 45.0,
            "satellite_change": 30.0,
            "field_reports_count": 0,
            "population_affected": 8900,
            "roads_affected": 4
        },
        {
            "name": "Dima Hasao Hill Highway (NH-27)",
            "district": "Dima Hasao",
            "state": "Assam",
            "latitude": 25.1764,
            "longitude": 93.0142,
            "rainfall": 105.0,
            "soil_moisture": 81.0,
            "slope": 33.0,
            "historical_risk": 80.0,
            "satellite_change": 70.0,
            "field_reports_count": 4,
            "population_affected": 9400,
            "roads_affected": 18
        },
        {
            "name": "Ri-Bhoi Expressway Cut",
            "district": "Ri-Bhoi",
            "state": "Meghalaya",
            "latitude": 25.9048,
            "longitude": 91.8804,
            "rainfall": 55.0,
            "soil_moisture": 58.0,
            "slope": 24.0,
            "historical_risk": 40.0,
            "satellite_change": 25.0,
            "field_reports_count": 0,
            "population_affected": 4100,
            "roads_affected": 3
        },
        {
            "name": "South Garo Hills Cliff Zone",
            "district": "South Garo Hills",
            "state": "Meghalaya",
            "latitude": 25.2630,
            "longitude": 90.6277,
            "rainfall": 68.0,
            "soil_moisture": 64.0,
            "slope": 31.0,
            "historical_risk": 55.0,
            "satellite_change": 35.0,
            "field_reports_count": 1,
            "population_affected": 5200,
            "roads_affected": 4
        },
        {
            "name": "West Kameng Highway",
            "district": "West Kameng",
            "state": "Arunachal Pradesh",
            "latitude": 27.3200,
            "longitude": 92.2300,
            "rainfall": 22.0,
            "soil_moisture": 38.0,
            "slope": 29.0,
            "historical_risk": 35.0,
            "satellite_change": 20.0,
            "field_reports_count": 0,
            "population_affected": 3100,
            "roads_affected": 2
        },
        {
            "name": "Imphal East Ridge",
            "district": "Imphal East",
            "state": "Manipur",
            "latitude": 24.8170,
            "longitude": 93.9500,
            "rainfall": 40.0,
            "soil_moisture": 49.0,
            "slope": 22.0,
            "historical_risk": 30.0,
            "satellite_change": 18.0,
            "field_reports_count": 0,
            "population_affected": 7800,
            "roads_affected": 3
        },
        {
            "name": "Mokokchung North Pass",
            "district": "Mokokchung",
            "state": "Nagaland",
            "latitude": 26.3243,
            "longitude": 94.5242,
            "rainfall": 18.0,
            "soil_moisture": 32.0,
            "slope": 20.0,
            "historical_risk": 25.0,
            "satellite_change": 15.0,
            "field_reports_count": 0,
            "population_affected": 2400,
            "roads_affected": 1
        },
        {
            "name": "Champhai Border Road",
            "district": "Champhai",
            "state": "Mizoram",
            "latitude": 23.4720,
            "longitude": 93.3260,
            "rainfall": 60.0,
            "soil_moisture": 65.0,
            "slope": 34.0,
            "historical_risk": 58.0,
            "satellite_change": 42.0,
            "field_reports_count": 1,
            "population_affected": 4500,
            "roads_affected": 4
        },
        {
            "name": "East Jaintia Hills Coal Cut Slope",
            "district": "East Jaintia Hills",
            "state": "Meghalaya",
            "latitude": 25.3214,
            "longitude": 92.3486,
            "rainfall": 78.0,
            "soil_moisture": 73.0,
            "slope": 37.0,
            "historical_risk": 68.0,
            "satellite_change": 55.0,
            "field_reports_count": 2,
            "population_affected": 6800,
            "roads_affected": 6
        },
        {
            "name": "West Khasi Hills Rural Sector",
            "district": "West Khasi Hills",
            "state": "Meghalaya",
            "latitude": 25.5255,
            "longitude": 91.2464,
            "rainfall": 15.0,
            "soil_moisture": 28.0,
            "slope": 18.0,
            "historical_risk": 20.0,
            "satellite_change": 10.0,
            "field_reports_count": 0,
            "population_affected": 1900,
            "roads_affected": 1
        },
        {
            "name": "Agartala Foothill Section",
            "district": "West Tripura",
            "state": "Tripura",
            "latitude": 23.8315,
            "longitude": 91.2868,
            "rainfall": 12.0,
            "soil_moisture": 25.0,
            "slope": 14.0,
            "historical_risk": 15.0,
            "satellite_change": 8.0,
            "field_reports_count": 0,
            "population_affected": 5500,
            "roads_affected": 2
        }
    ]

    zones_db = []
    for z in raw_zones:
        calc = calculate_landslide_risk(
            rainfall=z["rainfall"],
            soil_moisture=z["soil_moisture"],
            slope=z["slope"],
            historical_risk=z["historical_risk"],
            satellite_change=z["satellite_change"],
            field_reports=z["field_reports_count"]
        )
        
        zone_obj = Zone(
            name=z["name"],
            district=z["district"],
            state=z["state"],
            latitude=z["latitude"],
            longitude=z["longitude"],
            rainfall=z["rainfall"],
            soil_moisture=z["soil_moisture"],
            slope=z["slope"],
            historical_risk=z["historical_risk"],
            satellite_change=z["satellite_change"],
            field_reports_count=z["field_reports_count"],
            risk_score=calc["riskScore"],
            risk_level=calc["riskLevel"],
            population_affected=z["population_affected"],
            roads_affected=z["roads_affected"],
            recommended_action=calc["recommendation"],
            last_updated=datetime.now(timezone.utc)
        )
        db.add(zone_obj)
        db.flush()
        zones_db.append(zone_obj)

    # Initial Alerts
    alerts = [
        Alert(
            alert_code="TG-1024",
            zone_id=zones_db[0].id,
            zone_name=zones_db[0].name,
            district=zones_db[0].district,
            risk_score=zones_db[0].risk_score,
            alert_level=zones_db[0].risk_level,
            trigger_reason="Heavy rainfall + soil saturation + 3 field reports",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=25),
            recipients="District Disaster Management Authority, Field Officials, Residents",
            status="Active",
            acknowledged=True,
            sms_sent=True,
            ivr_activated=True
        ),
        Alert(
            alert_code="TG-1025",
            zone_id=zones_db[5].id,
            zone_name=zones_db[5].name,
            district=zones_db[5].district,
            risk_score=zones_db[5].risk_score,
            alert_level=zones_db[5].risk_level,
            trigger_reason="Monsoon surge & steep cut slope along NH-27",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=45),
            recipients="Highway Authority, District Admin",
            status="Active",
            acknowledged=False,
            sms_sent=True,
            ivr_activated=False
        ),
        Alert(
            alert_code="TG-1026",
            zone_id=zones_db[1].id,
            zone_name=zones_db[1].name,
            district=zones_db[1].district,
            risk_score=zones_db[1].risk_score,
            alert_level=zones_db[1].risk_level,
            trigger_reason="High slope instability & 94mm rainfall",
            timestamp=datetime.now(timezone.utc) - timedelta(hours=2),
            recipients="Sikkim State Disaster Control",
            status="Active",
            acknowledged=True,
            sms_sent=True,
            ivr_activated=False
        )
    ]
    for a in alerts:
        db.add(a)

    # Initial Citizen Reports
    reports = [
        Report(
            report_code="TG-RPT-1040",
            reporter_type="Field Official",
            district="East Khasi Hills",
            location_name="Nongpriang Slope Road near km 12",
            latitude=25.3210,
            longitude=91.7015,
            issue_type="Crack",
            severity="Critical",
            description="Deep 4-inch tension crack observed running parallel to the retaining wall along hill curve.",
            photo_url="https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=40),
            status="Verified",
            verified_by="Inspector R. Sangma",
            zone_id=zones_db[0].id
        ),
        Report(
            report_code="TG-RPT-1041",
            reporter_type="Citizen",
            district="Dima Hasao",
            location_name="NH-27 Junction Slope",
            latitude=25.1780,
            longitude=93.0160,
            issue_type="Road blockage",
            severity="High",
            description="Minor rockfall blocking left lane. Continuous water seepage from upper cliff face.",
            photo_url="https://images.unsplash.com/photo-1508873696983-2df515122519?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=15),
            status="Pending Verification",
            verified_by=None,
            zone_id=zones_db[5].id
        ),
        Report(
            report_code="TG-RPT-1042",
            reporter_type="Citizen",
            district="Aizawl",
            location_name="Bawngkawn Slope Settlement",
            latitude=23.7290,
            longitude=92.7180,
            issue_type="Slope movement",
            severity="Medium",
            description="Trees leaning downhill and mud sliding near drainage channel.",
            photo_url="https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.now(timezone.utc) - timedelta(hours=1),
            status="Verified",
            verified_by="Officer L. Mizorama",
            zone_id=zones_db[3].id
        )
    ]
    for r in reports:
        db.add(r)

    # Initial Audit Logs
    logs = [
        AuditLog(
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=50),
            event_type="System Init",
            zone_name=None,
            details="TerraGuard NER Risk Engine & GIS Monitoring initialized for North Eastern Region",
            action_by="System Kernel"
        ),
        AuditLog(
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=45),
            event_type="Alert Generated",
            zone_name="Dima Hasao Hill Highway (NH-27)",
            details="WARNING alert TG-1025 generated due to 105mm rainfall",
            action_by="AI Risk Engine"
        ),
        AuditLog(
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=25),
            event_type="Alert Generated",
            zone_name="East Khasi Hills (Nongpriang)",
            details="EVACUATE alert TG-1024 triggered. Score: 84.5. SMS broadcast dispatched.",
            action_by="AI Risk Engine"
        ),
        AuditLog(
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=20),
            event_type="Report Verified",
            zone_name="East Khasi Hills (Nongpriang)",
            details="Citizen report TG-RPT-1040 verified by Inspector R. Sangma. Score updated.",
            action_by="Inspector R. Sangma"
        )
    ]
    for l in logs:
        db.add(l)

    db.commit()
    db.close()
    print("Database successfully seeded with 15 NER zones, initial alerts, reports, and logs!")

if __name__ == "__main__":
    seed_database()
