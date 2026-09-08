from sqlalchemy import text
from app.database import engine, SessionLocal

def migrate_roads_table():
    """Create the road_status table"""
    db = SessionLocal()
    
    try:
        # Create road_status table
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS road_status (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            road_id VARCHAR UNIQUE NOT NULL,
            road_name VARCHAR NOT NULL,
            start_location VARCHAR,
            end_location VARCHAR,
            district VARCHAR,
            status VARCHAR DEFAULT 'OPEN',
            blockage_reason VARCHAR,
            latitude REAL,
            longitude REAL,
            risk_score REAL DEFAULT 0.0,
            blocked_at DATETIME,
            cleared_at DATETIME,
            blocked_by VARCHAR,
            cleared_by VARCHAR,
            affected_citizens_count INTEGER DEFAULT 0,
            alternative_route_available BOOLEAN DEFAULT 1,
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        """
        
        db.execute(text(create_table_sql))
        db.commit()
        
        print("✅ Road status table created successfully")
        
        # Insert sample roads
        sample_roads = [
            {
                "road_id": "RD-101",
                "road_name": "Shillong - Cherrapunji Highway",
                "start_location": "Shillong",
                "end_location": "Cherrapunji",
                "district": "East Khasi Hills",
                "status": "OPEN",
                "latitude": 25.57,
                "longitude": 91.87
            },
            {
                "road_id": "RD-102",
                "road_name": "Guwahati - Shillong Road",
                "start_location": "Guwahati",
                "end_location": "Shillong",
                "district": "East Khasi Hills",
                "status": "OPEN",
                "latitude": 26.15,
                "longitude": 91.79
            },
            {
                "road_id": "RD-103",
                "road_name": "Tawang - Bomdila Road",
                "start_location": "Tawang",
                "end_location": "Bomdila",
                "district": "West Kameng",
                "status": "OPEN",
                "latitude": 27.58,
                "longitude": 91.91
            }
        ]
        
        for road in sample_roads:
            insert_sql = """
            INSERT OR IGNORE INTO road_status 
            (road_id, road_name, start_location, end_location, district, status, latitude, longitude)
            VALUES (:road_id, :road_name, :start_location, :end_location, :district, :status, :latitude, :longitude)
            """
            db.execute(text(insert_sql), road)
        
        db.commit()
        print("✅ Sample roads inserted successfully")
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    migrate_roads_table()
