from sqlalchemy import text
from app.database import engine, Base
from app.models import CitizenUser, AdminUser

def migrate_database():
    """Add new authentication tables and columns"""
    
    # Create all tables (this will add new tables if they don't exist)
    Base.metadata.create_all(bind=engine)
    
    # Add new columns to existing CitizenUser table
    with engine.connect() as conn:
        # Check if role column exists
        result = conn.execute(text("PRAGMA table_info(citizen_users)"))
        columns = [row[1] for row in result]
        
        if 'role' not in columns:
            conn.execute(text("ALTER TABLE citizen_users ADD COLUMN role VARCHAR DEFAULT 'CITIZEN'"))
            print("Added 'role' column to citizen_users")
        
        if 'otp_verified' not in columns:
            conn.execute(text("ALTER TABLE citizen_users ADD COLUMN otp_verified BOOLEAN DEFAULT 0"))
            print("Added 'otp_verified' column to citizen_users")
        
        if 'is_active' not in columns:
            conn.execute(text("ALTER TABLE citizen_users ADD COLUMN is_active BOOLEAN DEFAULT 1"))
            print("Added 'is_active' column to citizen_users")
        
        conn.commit()
    
    print("Database migration completed successfully!")

if __name__ == "__main__":
    migrate_database()
