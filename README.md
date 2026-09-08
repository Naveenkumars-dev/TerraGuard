# TerraGuard NER – AI-Based Early Warning & Landslide Risk Monitoring System

**Smart India Hackathon 2026 Prototype**  
**Problem Statement:** SIH26001  
**Organization:** Ministry of Development of North Eastern Region (MDoNER)  
**Theme:** Disaster Management  

---

## 📌 Executive Summary

**TerraGuard NER** is a dynamic, GIS-enabled early warning platform designed for the North Eastern Region of India (NER). It fuses fragmented environmental telemetry (rainfall, soil moisture, terrain slope, satellite indicators, historical landslide frequency, and crowdsourced field reports) into an **explainable dynamic landslide risk score**, visualizes high-risk zones on a responsive interactive map, and dispatches automated tiered alerts with low-bandwidth SMS/IVR fallbacks.

---

## 🚀 Key Features

1. **Disaster Management Command Center**: Live KPIs showing active high-risk zones, warning zones, population/roads at risk, and alert counts.
2. **Interactive GIS Risk Map**: Leaflet map centered on North East India (Assam, Meghalaya, Sikkim, Arunachal Pradesh, Nagaland, Manipur, Mizoram, Tripura) rendering color-coded risk zones (SAFE: Green, WATCH: Yellow, WARNING: Orange, EVACUATE: Red).
3. **Explainable AI Risk Engine**: Weighted multi-factor risk score calculation (Rainfall 30%, Soil Moisture 20%, Slope 20%, Historical Risk 15%, Satellite Change 10%, Field Reports 5%) accompanied by confidence scores and human-understandable AI narrative summaries.
4. **Simulated Heavy Rainfall Cloudburst Action**: Real-time event simulator escalating zone risk scores, triggering active alerts, updating audit logs, and displaying simulated SMS/IVR alert notifications.
5. **Citizen-in-the-Loop Reporting & Verification**: Crowdsourced distress reporting (tension cracks, slope movements, rockfalls, road blockages) with GPS capture, photo attachment, and admin verification queue. Verified reports dynamically increase zone risk scores.
6. **Low-Bandwidth Mode**: Switch to compact high-contrast cards, cached risk status indicators, and SMS protocol banners for remote connectivity environments.
7. **Guided Demo Mode for SIH Judges**: 5-step interactive presentation scenario runner demonstrating end-to-end hazard detection in under 3 minutes.
8. **Historical Analytics & Administration**: Recharts visualizer for incident trends, threshold cutoffs configuration, and telemetric data source health.

---

## 🛠️ Technology Stack

* **Frontend**: React 18, Vite, Tailwind CSS, Leaflet, Lucide React, Recharts
* **Backend**: Python 3.14, FastAPI, SQLAlchemy, SQLite, Pydantic, Scikit-Learn
* **Database**: SQLite (`terraguard.db`)
* **iOS**: SwiftUI, UIKit

---

## ⚙️ Installation & Setup

### Prerequisites
* Python 3.9+
* Node.js 18+

### 1. Backend Setup

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python seed_data.py
python run.py
```

* Backend API will be live at: `http://localhost:8000`
* Interactive API Documentation (Swagger): `http://localhost:8000/docs`

### 2. Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

* Frontend Application will be live at: `http://localhost:3000`

### 3. iOS App Setup

#### Prerequisites
* Xcode 14.0 or later
* macOS 12.0 or later
* iOS 15.0+ deployment target

#### Setting up the iOS Project

Since Xcode is not installed on the current system, you'll need to set up the project on a Mac with Xcode:

1. **Open Xcode** and create a new project:
   - Select **App** under iOS tab
   - Product Name: `TerraGuardApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None`

2. **Replace the default ContentView.swift** with the views in `ios/TerraGuardApp/Views/`:
   - Copy all SwiftUI view files to your Xcode project
   - Ensure all files are added to the target

3. **Add the Models**:
   - Copy `ios/TerraGuardApp/Models/` files to your project
   - Add them to the target

4. **Configure the App**:
   - Set `TerraGuardApp.swift` as the main app entry point
   - Ensure `MainTabView` is set as the root view

5. **Build and Run**:
   - Select a simulator or connected device
   - Press Cmd+R to build and run

#### iOS App Features

The iOS app includes 5 main modules:

1. **🏠 Dashboard**: Overview of current risk status and emergency response flow
2. **🚨 Alerts**: Emergency alarm with "I AM SAFE" / "I NEED HELP" status reporting and rescue dashboard
3. **🚧 Road Intelligence**: AI-powered multi-source road blockage detection with evacuation route optimization
4. **🏠 Shelter & Resources**: Smart shelter allocation and AI resource distribution
5. **📡 Emergency Communication**: Online/Offline mode toggle with RF gateway and button phone simulation

---

## 🎯 3–5 Minute SIH Judge Demonstration Scenario

1. **Step 1 - Open Dashboard**: Inspect the North Eastern Region command center, KPI metrics cards, and connected data sources.
2. **Step 2 - Inspect High-Risk Zone**: Click **East Khasi Hills** on the Leaflet map to inspect the Explainable AI panel breaking down factor impacts (85mm Rainfall, 82% Soil Moisture, 37° Slope).
3. **Step 3 - Simulate Cloudburst Event**: Click **"Simulate Heavy Rainfall Event"**. Observe real-time risk escalation from **WARNING (74)** to **EVACUATE (84.5)**.
4. **Step 4 - Review Alert & SMS**: A simulated SMS broadcast modal ("TERRAGUARD ALERT: EVACUATE NOW...") and IVR fallback badge will appear instantly.
5. **Step 5 - Submit Citizen Field Report**: Switch role to **Citizen**, navigate to **Field/Citizen Reports**, capture GPS coordinates, attach photo link, and submit a tension crack report.
6. **Step 6 - Admin Verification**: Switch role to **District Admin**, click **Verify & Escalate Risk** on the pending report, and watch the risk score update and report marker appear on the Leaflet map.
7. **Step 7 - Low-Bandwidth Mode & Guided Demo Mode**: Toggle **Low-Bandwidth Mode** in the header to view cached SMS fallback mode, or click **Demo Mode** to run the 5-step guided SIH presentation scenario.

---

## ⚠️ Prototype vs Production Disclaimer

| Component | Prototype (SIH Demo) | Production Implementation |
| :--- | :--- | :--- |
| **Rainfall Data** | Simulated cloudburst feeds | Live IMD Automatic Weather Station (AWS) API |
| **Satellite Change** | Mock change index values | ISRO Bhuvan / Sentinel-2 Earth Observation API |
| **SMS Broadcast** | Interactive simulated popup modal | Government NIC SMS Gateway / C-DOT CAP Cell Broadcast |
| **Hardware Sensors** | Simulated telemetric grid | IoT TDR Soil Moisture & Tiltmeter sensor arrays |
| **Authentication** | Role selector dropdown | Aadhaar / MeriPechana Gov SS0 |
