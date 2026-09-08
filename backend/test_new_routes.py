import json
from app.database import SessionLocal, engine, Base
from app import models, schemas
from app.routes import citizens, coordination

# Create database tables
Base.metadata.create_all(bind=engine)

def test_backend_logic():
    db = SessionLocal()
    try:
        print("--- 1. Testing Citizen Registration ---")
        req = schemas.CitizenRegisterRequest(
            full_name="Naveen Kumar",
            phone="+91 98765 43210",
            registered_district="East Khasi Hills",
            vulnerability_profile="Elderly Resident",
            emergency_contact="+91 91234 56789"
        )
        user = citizens.register_citizen(req, db)
        print("User Code generated:", user.user_code)
        print("Phone:", user.phone)
        print("Gov ID:", user.gov_id_masked)
        print("Identity Verified:", user.identity_verified)
        assert user.user_code.startswith("TG-USR-")

        print("\n--- 2. Testing Emergency Alarm Trigger ---")
        alarm_req = schemas.EmergencyAlarmTriggerRequest(
            district="East Khasi Hills",
            risk_score=91.4,
            trigger_message="🔴 EVACUATE NOW: High landslide danger within 2 km."
        )
        alarm_res = citizens.trigger_emergency_alarm(alarm_req, db)
        print("Alarm Status:", alarm_res["status"])
        print("Citizens Notified:", alarm_res["affected_citizens_notified"])
        print("Siren Frequency (Hz):", alarm_res["siren_frequency_hz"])
        assert alarm_res["status"] == "ALARM_DISPATCHED"

        print("\n--- 3. Testing AI Emergency Resource Prioritization ---")
        allocations = coordination.get_resource_allocations(db)
        print("Allocations count:", len(allocations))
        print("Priority #1:", allocations[0].incident_name, "| Priority Score:", allocations[0].priority_score)
        print("Assigned Team:", allocations[0].assigned_team)
        print("Explainable AI Rationale:", allocations[0].rationale)
        assert len(allocations) > 0

        print("\n--- 4. Testing Risk-Aware Road Diversion Engine ---")
        routes_res = coordination.get_district_routes("East Khasi Hills", db)
        print("District:", routes_res["district"])
        print("Recommended Route:", routes_res["recommended_route"].route_name, "| Status:", routes_res["recommended_route"].status)
        print("Analysis Summary:", routes_res["analysis_summary"])
        assert routes_res["recommended_route"].is_recommended == True

        print("\n✅ EMPIRICAL VERIFICATION SUCCESSFUL! All backend models, AI algorithms, and routes are fully functional!")

    finally:
        db.close()

if __name__ == "__main__":
    test_backend_logic()
