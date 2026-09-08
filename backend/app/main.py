from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.routes import zones, risk, alerts, reports, analytics, system, demo, citizens, coordination, roads

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="TerraGuard NER - Landslide Risk Monitoring API",
    description="AI-Based Early Warning & Landslide Risk Engine for North Eastern Region (SIH26001 Prototype)",
    version="1.0.0"
)

# CORS Middleware setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(zones.router)
app.include_router(risk.router)
app.include_router(alerts.router)
app.include_router(reports.router)
app.include_router(analytics.router)
app.include_router(system.router)
app.include_router(demo.router)
app.include_router(citizens.router)
app.include_router(coordination.router)
app.include_router(roads.router)


@app.get("/")
def root():
    return {
        "system": "TerraGuard NER",
        "status": "ONLINE",
        "prototype": "SIH26001 - AI-Based Early Warning and Landslide Risk Monitoring System",
        "organization": "Ministry of Development of North Eastern Region (MDoNER)",
        "docs": "/docs"
    }

@app.get("/api/health")
def health_check():
    return {"status": "healthy"}
