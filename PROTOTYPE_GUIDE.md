# TerraGuard Prototype Guide
## SIH26001 - AI-Based Early Warning and Landslide Risk Monitoring System

---

## � Offline Mode

### Progressive Web App (PWA)
TerraGuard is a PWA that works both online and offline:

**Online Mode:**
- Real-time data from backend API
- Live risk monitoring
- Emergency alert triggers
- Road management updates

**Offline Mode:**
- Service Worker caches application assets
- IndexedDB stores zones, alerts, reports
- Cached data displayed when offline
- "OFFLINE MODE" banner shown in header
- Limited functionality (no real-time updates)

### Offline Data Storage
- **IndexedDB** stores: zones, alerts, reports, roads, citizens
- **Service Worker** caches: HTML, CSS, JS, manifest
- **Fallback**: Mock data when cache unavailable

### Testing Offline Mode
1. Open http://localhost:3003
2. Navigate through the app to load data
3. Disconnect network (or use DevTools → Network → Offline)
4. App continues to work with cached data
5. Red "OFFLINE MODE" banner appears in header
6. Reconnect network → app switches back to online mode

### PWA Installation
- Chrome/Edge: Click install icon in address bar
- Safari: Add to Home Screen
- Android: Install from browser menu
- iOS: Add to Home Screen

---

## �🚀 Quick Start

### Backend Server
```bash
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Backend runs at: http://localhost:8000

### Frontend Application
```bash
cd frontend
npm start
```
Frontend runs at: http://localhost:3003

---

## 👥 User Roles & Authentication

### 1. Citizen Role
**Access:** Landing Page → Select "Citizen" → Register/Login

**Features:**
- Aadhaar verification (simulated: enter any 12 digits)
- OTP verification (demo OTP: 123456)
- Route alerts for blocked roads
- Emergency alarm notifications
- Safe alternative route navigation

**Dashboard:** Shows Travel & Route Alerts

### 2. Admin Role
**Access:** Landing Page → Select "Admin / Government Officer" → Register/Login

**Features:**
- Government ID verification (simulated)
- Risk monitoring dashboard
- Emergency alert trigger
- Road management (block/clear roads)
- System analytics

**Dashboard:** Shows Command Center with all monitoring features

---

## 🎯 Complete Feature Workflow

### Feature 1: Emergency Alert System

**Citizen Flow:**
1. Citizen logs in → Dashboard shows route alerts
2. If road blocked → Alert displayed with "VIEW SAFE ROUTE" button
3. Click button → Google Maps shows alternative route
4. When road cleared → "ROUTE RESTORED" notification

**Admin Flow:**
1. Admin logs in → Navigate to "Alert Dispatch" tab
2. Configure risk level (SAFE/WATCH/WARNING/HIGH/CRITICAL)
3. Set risk score and affected area
4. Click "SEND EMERGENCY ALERT"
5. Citizens receive 60-second alarm with sound & vibration

**API Endpoints:**
- `POST /api/citizens/trigger-alarm` - Trigger emergency alert
- `GET /api/roads/blocked` - Get blocked roads
- `POST /api/roads/block` - Block a road
- `POST /api/roads/clear` - Clear a road

---

### Feature 2: Intelligent Safe Route Navigation

**Workflow:**
```
Landslide Detected → Road Blocked → Citizen Notified → 
Alternative Route Shown → Google Maps Navigation → 
Road Cleared → Citizen Notified → Regular Route Restored
```

**Citizen Portal:**
- Dashboard shows blocked roads
- Displays road details (name, location, reason)
- Shows affected citizens count
- "VIEW SAFE ROUTE" opens Google Maps
- Route restoration notifications

**Admin Portal:**
- "Administration" tab shows Road Management
- View all roads with status (OPEN/BLOCKED)
- Block roads (simulates landslide detection)
- Clear roads (simulates restoration)
- Statistics: Total roads, blocked roads, open roads

**API Endpoints:**
- `GET /api/roads` - Get all roads
- `GET /api/roads/blocked` - Get blocked roads
- `POST /api/roads/block` - Block a road
- `POST /api/roads/clear` - Clear a road

---

### Feature 3: Risk Monitoring Dashboard

**Admin Features:**
- Real-time risk scores for all zones
- Risk level indicators (SAFE/WATCH/WARNING/EVACUATE)
- Environmental factors (rainfall, soil moisture, slope)
- Historical risk data
- Satellite change detection
- Field reports count

**API Endpoints:**
- `GET /api/zones` - Get all zones
- `GET /api/zones/{id}` - Get specific zone
- `GET /api/zones?district={name}` - Get zones by district

---

### Feature 4: Citizen Registration & Authentication

**Registration Flow:**
1. Enter name, phone, Aadhaar (XXXX XXXX 1234 format)
2. Select district
3. Enter emergency contact
4. Submit → OTP sent (demo: 123456)
5. Verify OTP → Account created
6. Shows: ✓ Identity Verified, ✓ Mobile Registered, ✓ Emergency Alerts Enabled

**API Endpoints:**
- `POST /api/citizens/register` - Register citizen
- `POST /api/citizens/login` - Login citizen

---

### Feature 5: Admin Registration & Authentication

**Registration Flow:**
1. Enter full name, official email, phone
2. Enter government ID (PAN/Employee ID/etc.)
3. Select department, designation, district
4. Submit → Government ID verified (simulated)
5. Account created with admin privileges

**API Endpoints:**
- `POST /api/citizens/admin/register` - Register admin
- `POST /api/citizens/login` - Login admin

---

## 📱 iOS Application Features

### Views Implemented:
1. **LandingPageView** - Role selection (Citizen/Admin)
2. **CitizenAuthView** - Citizen registration/login
3. **AdminAuthView** - Admin registration/login
4. **DashboardView** - Risk overview
5. **AlertsView** - Emergency alerts with alarm test
6. **RouteAlertView** - Route alerts with Apple Maps
7. **RoadIntelligenceView** - Road blockage detection
8. **ShelterResourceView** - Shelter & resource allocation
9. **EmergencyCommunicationView** - RF gateway communication

### Emergency Alarm (iOS):
- 60-second alarm with sound
- Device vibration
- Full-screen emergency notification
- Countdown timer
- Stop button

---

## 🗄️ Database Schema

### Tables:
1. **zones** - Landslide risk zones
2. **alerts** - Emergency alerts
3. **reports** - Field/citizen reports
4. **audit_logs** - System audit trail
5. **system_config** - System configuration
6. **citizen_users** - Citizen accounts
7. **admin_users** - Admin accounts
8. **road_status** - Road blockage status
9. **resource_allocations** - Emergency resources
10. **road_diversions** - Road diversions
11. **shelters** - Emergency shelters
12. **emergency_citizen_status** - Citizen emergency status
13. **road_blockage_multi_source** - Multi-source blockage detection
14. **rf_gateway_config** - RF gateway configuration

---

## 🧪 Testing the Prototype

### Test 1: Citizen Route Alerts
1. Open http://localhost:3003
2. Select "Citizen"
3. Register with Aadhaar: XXXX XXXX 1234
4. Enter OTP: 123456
5. View Dashboard → Should show blocked road alert
6. Click "VIEW SAFE ROUTE" → Opens Google Maps modal

### Test 2: Admin Road Management
1. Open http://localhost:3003
2. Select "Admin / Government Officer"
3. Register with government ID
4. Navigate to "Administration" tab
5. View road list → Should show RD-101 as BLOCKED
6. Click "Clear Road" → Road status changes to OPEN
7. Click "Block Road" → Road status changes to BLOCKED

### Test 3: Emergency Alert Trigger
1. Login as Admin
2. Navigate to "Alert Dispatch" tab
3. Set risk level to "CRITICAL"
4. Set risk score to 96
5. Click "SEND EMERGENCY ALERT"
6. Emergency alarm modal appears (60-second countdown)

### Test 4: Backend API
```bash
# Get all roads
curl http://localhost:8000/api/roads

# Get blocked roads
curl http://localhost:8000/api/roads/blocked

# Block a road
curl -X POST http://localhost:8000/api/roads/block \
  -H "Content-Type: application/json" \
  -d '{"road_id": "RD-102", "blockage_reason": "LANDSLIDE"}'

# Clear a road
curl -X POST http://localhost:8000/api/roads/clear \
  -H "Content-Type: application/json" \
  -d '{"road_id": "RD-102"}'
```

---

## 🎨 UI Components

### Web Components:
- **LandingPage** - Role selection cards
- **CitizenAuth** - Citizen registration/login
- **AdminAuth** - Admin registration/login
- **RouteAlert** - Citizen route alerts
- **RoadManagement** - Admin road management
- **EmergencyAlertTrigger** - Admin emergency alert trigger
- **Dashboard** - Risk monitoring dashboard
- **Header** - Top navigation with user info
- **Sidebar** - Navigation menu
- **DemoModeBar** - Demo mode controls

### iOS Components:
- **LandingPageView** - SwiftUI role selection
- **CitizenAuthView** - SwiftUI citizen auth
- **AdminAuthView** - SwiftUI admin auth
- **RouteAlertView** - SwiftUI route alerts
- **EmergencyAlertView** - SwiftUI emergency alarm
- **DashboardView** - SwiftUI dashboard
- **AlertsView** - SwiftUI alerts
- **MainTabView** - Main navigation

---

## 🔧 Configuration

### Backend Configuration:
- Database: SQLite (terraguard.db)
- API Base: http://localhost:8000
- CORS: Enabled for all origins

### Frontend Configuration:
- API Base: http://localhost:8000
- Frontend Port: 3003
- Demo Mode: Enabled

---

## 📊 Sample Data

### Sample Roads:
- RD-101: Shillong - Cherrapunji Highway (OPEN)
- RD-102: Guwahati - Shillong Road (OPEN)
- RD-103: Tawang - Bomdila Road (OPEN)

### Sample Zones:
- East Khasi Hills (Nongpriang) - EVACUATE (88% risk)
- Dima Hasao Hill Highway - WARNING (79% risk)
- Gangtok Ridge North - WARNING (72% risk)

---

## 🎯 Key Features Summary

1. **✅ Role-based Authentication** - Citizen and Admin roles
2. **✅ Aadhaar Verification** - Simulated identity verification
3. **✅ Emergency Alert System** - 60-second alarm with sound & vibration
4. **✅ Intelligent Route Navigation** - Google Maps integration
5. **✅ Road Management** - Block/clear roads
6. **✅ Risk Monitoring** - Real-time risk scores
7. **✅ Citizen Notifications** - Route restoration alerts
8. **✅ Admin Dashboard** - Complete monitoring interface
9. **✅ iOS Application** - Full SwiftUI implementation
10. **✅ Backend API** - RESTful API with database

---

## 📝 Notes

- All verifications are simulated for demo purposes
- Google Maps API key placeholder: Replace "YOUR_API_KEY" in RouteAlert.jsx
- Emergency alarm uses browser audio API (may require user interaction)
- iOS uses Apple Maps for navigation
- Database migrations: Run migrate_roads.py to create road_status table
- Backend auto-creates tables on startup

---

## 🎬 Demo Presentation Flow

**For SIH Judges:**

1. **Landing Page** - Show role selection
2. **Citizen Registration** - Show Aadhaar verification
3. **Citizen Dashboard** - Show route alerts for blocked road
4. **Safe Route** - Show Google Maps alternative route
5. **Admin Dashboard** - Show road management
6. **Block Road** - Demonstrate blocking a road
7. **Emergency Alert** - Trigger emergency alarm
8. **Clear Road** - Demonstrate road restoration
9. **Route Restored** - Show citizen notification

**One-line description:**
> "When a landslide blocks a citizen's regular route, TerraGuard automatically identifies the affected road, provides a safe alternative route through Google Maps, and notifies citizens when the original route is cleared."
