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

    # 25 Comprehensive zones across all NER (North Eastern Region of India) states
    raw_zones = [
        # ARUNACHAL PRADESH
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
            "name": "Itanagar Hill Slope",
            "district": "Papum Pare",
            "state": "Arunachal Pradesh",
            "latitude": 27.0520,
            "longitude": 93.6250,
            "rainfall": 65.0,
            "soil_moisture": 68.0,
            "slope": 32.0,
            "historical_risk": 55.0,
            "satellite_change": 45.0,
            "field_reports_count": 1,
            "population_affected": 9200,
            "roads_affected": 4
        },
        {
            "name": "Lower Dibang Valley",
            "district": "Lower Dibang Valley",
            "state": "Arunachal Pradesh",
            "latitude": 28.1450,
            "longitude": 95.7530,
            "rainfall": 78.0,
            "soil_moisture": 72.0,
            "slope": 40.0,
            "historical_risk": 68.0,
            "satellite_change": 55.0,
            "field_reports_count": 2,
            "population_affected": 4500,
            "roads_affected": 6
        },
        # ASSAM
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
            "name": "Karbi Anglong Plateau",
            "district": "Karbi Anglong",
            "state": "Assam",
            "latitude": 26.1820,
            "longitude": 93.3520,
            "rainfall": 85.0,
            "soil_moisture": 70.0,
            "slope": 28.0,
            "historical_risk": 60.0,
            "satellite_change": 48.0,
            "field_reports_count": 2,
            "population_affected": 11500,
            "roads_affected": 8
        },
        {
            "name": "Guwahati Hills Section",
            "district": "Kamrup Metropolitan",
            "state": "Assam",
            "latitude": 26.1830,
            "longitude": 91.7350,
            "rainfall": 72.0,
            "soil_moisture": 65.0,
            "slope": 25.0,
            "historical_risk": 48.0,
            "satellite_change": 38.0,
            "field_reports_count": 1,
            "population_affected": 25000,
            "roads_affected": 12
        },
        # MANIPUR
        {
            "name": "Imphal Valley East",
            "district": "Imphal East",
            "state": "Manipur",
            "latitude": 24.8170,
            "longitude": 94.0120,
            "rainfall": 68.0,
            "soil_moisture": 65.0,
            "slope": 22.0,
            "historical_risk": 52.0,
            "satellite_change": 35.0,
            "field_reports_count": 1,
            "population_affected": 7800,
            "roads_affected": 6
        },
        {
            "name": "Senapati Hill Range",
            "district": "Senapati",
            "state": "Manipur",
            "latitude": 25.2850,
            "longitude": 94.0820,
            "rainfall": 82.0,
            "soil_moisture": 74.0,
            "slope": 35.0,
            "historical_risk": 65.0,
            "satellite_change": 52.0,
            "field_reports_count": 2,
            "population_affected": 5200,
            "roads_affected": 5
        },
        {
            "name": "Churachandpur Terrain",
            "district": "Churachandpur",
            "state": "Manipur",
            "latitude": 24.4820,
            "longitude": 93.5520,
            "rainfall": 75.0,
            "soil_moisture": 68.0,
            "slope": 30.0,
            "historical_risk": 58.0,
            "satellite_change": 42.0,
            "field_reports_count": 1,
            "population_affected": 4200,
            "roads_affected": 4
        },
        # MEGHALAYA
        {
            "name": "East Khasi Hills (Nongpriang)",
            "district": "East Khasi Hills",
            "state": "Meghalaya",
            "latitude": 25.5700,
            "longitude": 91.8800,
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
            "name": "West Garo Hills Ridge",
            "district": "West Garo Hills",
            "state": "Meghalaya",
            "latitude": 25.5450,
            "longitude": 90.2150,
            "rainfall": 88.0,
            "soil_moisture": 75.0,
            "slope": 32.0,
            "historical_risk": 62.0,
            "satellite_change": 48.0,
            "field_reports_count": 2,
            "population_affected": 8800,
            "roads_affected": 7
        },
        {
            "name": "Jaintia Hills Mining Zone",
            "district": "East Jaintia Hills",
            "state": "Meghalaya",
            "latitude": 25.3214,
            "longitude": 92.3486,
            "rainfall": 95.0,
            "soil_moisture": 78.0,
            "slope": 36.0,
            "historical_risk": 72.0,
            "satellite_change": 58.0,
            "field_reports_count": 3,
            "population_affected": 6500,
            "roads_affected": 9
        },
        # MIZORAM
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
            "name": "Lunglei Terrain Section",
            "district": "Lunglei",
            "state": "Mizoram",
            "latitude": 22.8820,
            "longitude": 92.7550,
            "rainfall": 70.0,
            "soil_moisture": 64.0,
            "slope": 30.0,
            "historical_risk": 55.0,
            "satellite_change": 40.0,
            "field_reports_count": 1,
            "population_affected": 3800,
            "roads_affected": 4
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
        # NAGALAND
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
            "name": "Dimapur Road Section",
            "district": "Dimapur",
            "state": "Nagaland",
            "latitude": 25.9180,
            "longitude": 93.7320,
            "rainfall": 45.0,
            "soil_moisture": 48.0,
            "slope": 18.0,
            "historical_risk": 32.0,
            "satellite_change": 22.0,
            "field_reports_count": 0,
            "population_affected": 6200,
            "roads_affected": 3
        },
        # SIKKIM
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
            "name": "North Sikkim High Pass",
            "district": "North Sikkim",
            "state": "Sikkim",
            "latitude": 27.6830,
            "longitude": 88.6650,
            "rainfall": 110.0,
            "soil_moisture": 82.0,
            "slope": 45.0,
            "historical_risk": 75.0,
            "satellite_change": 68.0,
            "field_reports_count": 3,
            "population_affected": 3500,
            "roads_affected": 6
        },
        {
            "name": "West Sikkim Valley",
            "district": "West Sikkim",
            "state": "Sikkim",
            "latitude": 27.1520,
            "longitude": 88.2580,
            "rainfall": 78.0,
            "soil_moisture": 68.0,
            "slope": 30.0,
            "historical_risk": 52.0,
            "satellite_change": 40.0,
            "field_reports_count": 1,
            "population_affected": 4800,
            "roads_affected": 4
        },
        # TRIPURA
        {
            "name": "Agartala Slope Zone",
            "district": "West Tripura",
            "state": "Tripura",
            "latitude": 23.8315,
            "longitude": 91.2868,
            "rainfall": 45.0,
            "soil_moisture": 55.0,
            "slope": 18.0,
            "historical_risk": 38.0,
            "satellite_change": 28.0,
            "field_reports_count": 0,
            "population_affected": 5200,
            "roads_affected": 3
        },
        {
            "name": "Dhalai Terrain Hills",
            "district": "Dhalai",
            "state": "Tripura",
            "latitude": 23.8680,
            "longitude": 91.8820,
            "rainfall": 55.0,
            "soil_moisture": 60.0,
            "slope": 22.0,
            "historical_risk": 42.0,
            "satellite_change": 32.0,
            "field_reports_count": 1,
            "population_affected": 3600,
            "roads_affected": 3
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
            zone_id=zones_db[10].id,  # East Khasi Hills
            zone_name=zones_db[10].name,
            district=zones_db[10].district,
            risk_score=zones_db[10].risk_score,
            alert_level=zones_db[10].risk_level,
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
            zone_id=zones_db[4].id,  # Dima Hasao
            zone_name=zones_db[4].name,
            district=zones_db[4].district,
            risk_score=zones_db[4].risk_score,
            alert_level=zones_db[4].risk_level,
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
            zone_id=zones_db[21].id,  # Gangtok Ridge
            zone_name=zones_db[21].name,
            district=zones_db[21].district,
            risk_score=zones_db[21].risk_score,
            alert_level=zones_db[21].risk_level,
            trigger_reason="High slope instability & 94mm rainfall",
            timestamp=datetime.now(timezone.utc) - timedelta(hours=2),
            recipients="Sikkim State Disaster Control",
            status="Active",
            acknowledged=True,
            sms_sent=True,
            ivr_activated=False
        ),
        Alert(
            alert_code="TG-1027",
            zone_id=zones_db[22].id,  # North Sikkim High Pass
            zone_name=zones_db[22].name,
            district=zones_db[22].district,
            risk_score=zones_db[22].risk_score,
            alert_level=zones_db[22].risk_level,
            trigger_reason="High altitude extreme rainfall & steep terrain",
            timestamp=datetime.now(timezone.utc) - timedelta(hours=1),
            recipients="Sikkim Disaster Management, Border Roads",
            status="Active",
            acknowledged=False,
            sms_sent=True,
            ivr_activated=True
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
            latitude=25.5710,
            longitude=91.8815,
            issue_type="Crack",
            severity="Critical",
            description="Deep 4-inch tension crack observed running parallel to the retaining wall along hill curve.",
            photo_url="https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=40),
            status="Verified",
            verified_by="Inspector R. Sangma",
            zone_id=zones_db[10].id
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
            zone_id=zones_db[4].id
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
            zone_id=zones_db[14].id
        ),
        Report(
            report_code="TG-RPT-1043",
            reporter_type="Field Official",
            district="East Sikkim",
            location_name="Gangtok Ridge Access Road",
            latitude=27.3395,
            longitude=88.6140,
            issue_type="Slope movement",
            severity="Medium",
            description="Slow slope movement detected near ridge access. Ground displacement approximately 2cm.",
            photo_url="https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=120),
            status="Verified",
            verified_by="Surveyor T. Bhutia",
            zone_id=zones_db[21].id
        ),
        Report(
            report_code="TG-RPT-1044",
            reporter_type="Citizen",
            district="Senapati",
            location_name="Senapati Hill Range Road",
            latitude=25.2860,
            longitude=94.0830,
            issue_type="Rockfall",
            severity="High",
            description="Rockfall reported on main highway near Maram. Traffic partially affected.",
            photo_url="https://images.unsplash.com/photo-1508873696983-2df515122519?auto=format&fit=crop&w=600&q=80",
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=30),
            status="Pending Verification",
            verified_by=None,
            zone_id=zones_db[8].id
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
    print("Database successfully seeded with 25 NER zones covering all 8 states, initial alerts, reports, and logs!")

if __name__ == "__main__":
    seed_database()
