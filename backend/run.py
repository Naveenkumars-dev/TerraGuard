import uvicorn
import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from seed_data import seed_database

if __name__ == "__main__":
    # Ensure DB is seeded on first start
    try:
        seed_database()
    except Exception as e:
        print(f"Database seed note: {e}")

    print("Starting TerraGuard NER FastAPI Backend Server on http://0.0.0.0:8000 ...")
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
