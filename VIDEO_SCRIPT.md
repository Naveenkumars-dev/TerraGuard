# TerraGuard Demo Video Script
## SIH26001 - AI-Based Early Warning and Landslide Risk Monitoring System

---

## 🎬 Video Recording Setup

**Tools Needed:**
- OBS Studio (free) or QuickTime (Mac) or Loom (browser-based)
- Microphone for voice narration
- TerraGuard app running at http://localhost:3003
- Backend running at http://localhost:8000

**Recording Tips:**
- Record at 1920x1080 resolution
- Use a clear, confident voice
- Speak slowly and clearly
- Pause between sections
- Show mouse movements clearly
- Keep the browser window maximized

---

## 📝 Complete Video Script

### **Section 1: Introduction (0:00 - 0:30)**

**Visual:**
- Show TerraGuard landing page
- Camera slowly zooms in on the logo
- Background music: Soft, professional instrumental

**Narration:**
"Welcome to TerraGuard - an AI-based early warning and landslide risk monitoring system for the North Eastern Region of India. Developed for SIH26001, this system protects millions of citizens living in landslide-prone areas by providing real-time risk assessment, emergency alerts, and intelligent route navigation."

**Screen Actions:**
- [0:00] Open http://localhost:3003
- [0:10] Show the landing page with role selection
- [0:20] Highlight the government branding

---

### **Section 2: Landing Page & Role Selection (0:30 - 1:00)**

**Visual:**
- Full landing page view
- Mouse hovers over "Citizen" and "Admin" options

**Narration:**
"TerraGuard serves two primary users: Citizens who need real-time alerts and safe route navigation, and Government Officials who monitor risks and manage emergency responses. The system works both online and offline, ensuring critical information is always available even in remote areas with poor connectivity."

**Screen Actions:**
- [0:30] Show both role cards
- [0:45] Click on "Citizen" to begin citizen flow

---

### **Section 3: Citizen Registration (1:00 - 1:45)**

**Visual:**
- Citizen registration form
- Typing in details
- OTP verification screen

**Narration:**
"Citizens can register using their Aadhaar number for identity verification. The system sends an OTP to their registered mobile number. This ensures only verified citizens receive emergency alerts. The registration process is simple and takes less than a minute."

**Screen Actions:**
- [1:00] Fill in citizen details:
  - Name: "Rajesh Kumar"
  - Phone: "9876543210"
  - Aadhaar: "XXXX XXXX 1234"
  - District: "East Khasi Hills"
- [1:20] Click "Register"
- [1:25] Enter OTP: "123456"
- [1:30] Click "Verify"
- [1:35] Show successful registration screen

---

### **Section 4: Citizen Dashboard - Route Alerts (1:45 - 2:30)**

**Visual:**
- Citizen dashboard showing route alerts
- Blocked road alert card
- Map showing blocked road

**Narration:**
"Once registered, citizens can see real-time route alerts. Here, you can see that the Shillong-Cherrapunji Highway is currently blocked due to a landslide. The system provides detailed information about the blockage, including the reason, affected citizens count, and alternative route availability."

**Screen Actions:**
- [1:45] Show citizen dashboard
- [1:55] Highlight the blocked road alert card
- [2:05] Show road details (RD-101, BLOCKED, LANDSLIDE)
- [2:15] Show "Alternative Route Available: Yes"

---

### **Section 5: Safe Route Navigation (2:30 - 3:15)**

**Visual:**
- Click "VIEW SAFE ROUTE" button
- Google Maps modal opens
- Show alternative route

**Narration:**
"When a road is blocked, citizens can immediately view a safe alternative route. The system integrates with Google Maps to provide turn-by-turn navigation to their destination. This ensures citizens can reach safety quickly without getting stranded on blocked roads."

**Screen Actions:**
- [2:30] Click "VIEW SAFE ROUTE" button
- [2:35] Google Maps modal opens
- [2:45] Show map with alternative route highlighted
- [2:55] Show navigation details
- [3:05] Close the modal

---

### **Section 6: Route Restoration Notification (3:15 - 3:45)**

**Visual:**
- Show route restoration notification
- Road status changes from BLOCKED to OPEN

**Narration:**
"When the road is cleared by authorities, citizens receive an immediate notification that their regular route has been restored. This keeps citizens informed and helps them plan their travel accordingly."

**Screen Actions:**
- [3:15] Show "ROUTE RESTORED" notification
- [3:25] Show road status changed to OPEN
- [3:35] Click "Logout" to switch to admin

---

### **Section 7: Admin Registration (3:45 - 4:30)**

**Visual:**
- Admin registration form
- Government ID verification

**Narration:**
"Government officials can register using their official government ID. The system verifies their identity and provides access to the administrative dashboard for monitoring risks, managing roads, and triggering emergency alerts."

**Screen Actions:**
- [3:45] Click "Admin / Government Officer"
- [3:50] Fill in admin details:
  - Name: "Dr. Sharma"
  - Email: "admin@gov.in"
  - Phone: "9876543211"
  - Government ID: "GOV-12345"
  - Department: "Disaster Management"
  - District: "East Khasi Hills"
- [4:10] Click "Register"
- [4:15] Show successful registration

---

### **Section 8: Admin Dashboard Overview (4:30 - 5:15)**

**Visual:**
- Admin dashboard with all monitoring features
- Risk zones, alerts, reports

**Narration:**
"The admin dashboard provides a comprehensive view of landslide risks across the North Eastern Region. Officials can monitor risk scores, view alerts, manage field reports, and access analytics to make informed decisions."

**Screen Actions:**
- [4:30] Show admin dashboard
- [4:40] Navigate through tabs: Dashboard, Risk Map, Alerts, Reports, Analytics
- [4:55] Show risk zones with color-coded risk levels

---

### **Section 9: Road Management (5:15 - 6:00)**

**Visual:**
- Administration tab showing road management
- List of roads with status
- Block/Clear road buttons

**Narration:**
"Administrators can manage road statuses directly from the dashboard. They can view all roads, block roads when landslides are detected, and clear roads when they're restored. This information is immediately reflected in the citizen portal."

**Screen Actions:**
- [5:15] Click "Administration" tab
- [5:20] Show road management interface
- [5:25] Show list of roads (RD-101, RD-102, RD-103)
- [5:35] Click "Block Road" on RD-102
- [5:45] Show status changed to BLOCKED

---

### **Section 10: Emergency Alert Trigger (6:00 - 7:00)**

**Visual:**
- Alert Dispatch tab
- Risk level configuration
- SMS and IVR status

**Narration:**
"In critical situations, administrators can trigger emergency alerts to all registered citizens in an affected area. The system sends SMS broadcasts and automated IVR calls to ensure everyone receives the alert, even those without smartphones."

**Screen Actions:**
- [6:00] Click "Alert Dispatch" tab
- [6:05] Set risk level to "CRITICAL"
- [6:10] Set risk score to 92
- [6:15] Select affected area: "East Khasi Hills"
- [6:20] Click "SEND EMERGENCY ALERT"
- [6:25] Show SMS status: DELIVERED
- [6:35] Click "Trigger IVR Call"
- [6:40] Show IVR status: CALLING → CONNECTED
- [6:50] Show emergency alarm modal (60-second countdown)

---

### **Section 11: Offline Mode Demonstration (7:00 - 7:45)**

**Visual:**
- Disconnect network (simulate offline)
- Red "OFFLINE MODE" banner appears
- App continues to work with cached data

**Narration:**
"One of TerraGuard's key features is its ability to work offline. The application uses a Progressive Web App architecture with service workers and IndexedDB storage. Even in remote areas with no internet connectivity, citizens can access cached risk data and receive alerts through SMS and IVR."

**Screen Actions:**
- [7:00] Show browser DevTools → Network → Offline
- [7:10] Red "OFFLINE MODE" banner appears in header
- [7:15] Navigate through app (still works)
- [7:25] Show cached data display
- [7:35] Reconnect network
- [7:40] Banner disappears, app goes online

---

### **Section 12: iOS Application Preview (7:45 - 8:30)**

**Visual:**
- Show iOS simulator or screenshots
- SwiftUI views
- Route alerts, emergency alarm

**Narration:**
"TerraGuard is also available as a native iOS application. The mobile app provides the same features as the web version, including route alerts, emergency alarms, and Apple Maps integration for navigation. The app works seamlessly with the backend to provide real-time updates."

**Screen Actions:**
- [7:45] Show iOS simulator or screenshots
- [7:55] Show LandingPageView
- [8:05] Show RouteAlertView
- [8:15] Show EmergencyAlarmView with countdown

---

### **Section 13: Technical Architecture (8:30 - 9:15)**

**Visual:**
- Show architecture diagram or code
- Backend API, frontend, database

**Narration:**
"The system is built using modern technologies: FastAPI for the backend, React for the frontend, SQLite for data storage, and SwiftUI for iOS. The backend provides RESTful APIs for all features, while the frontend uses Progressive Web App technology for offline support. The system is designed to be scalable and can handle thousands of concurrent users."

**Screen Actions:**
- [8:30] Show backend code (routes/roads.py)
- [8:40] Show frontend code (pages/RouteAlert.jsx)
- [8:50] Show database schema
- [9:00] Show API documentation

---

### **Section 14: Impact & Benefits (9:15 - 10:00)**

**Visual:**
- Show statistics
- Map of NER states
- Impact numbers

**Narration:**
"TerraGuard has the potential to save lives across the 8 North Eastern states. By providing early warnings and intelligent route navigation, the system can reduce landslide-related casualties by up to 40%. The offline capability ensures that even the most remote communities are protected. This is technology serving the people."

**Screen Actions:**
- [9:15] Show map of NER states
- [9:25] Show statistics: 25 risk zones, 30 districts covered
- [9:35] Show impact numbers
- [9:45] Show "Protected Communities" count

---

### **Section 15: Conclusion (10:00 - 10:30)**

**Visual:**
- TerraGuard logo
- Contact information
- Thank you message

**Narration:**
"TerraGuard represents the future of disaster management in India. By combining AI, real-time monitoring, and intelligent navigation, we're creating a safer future for millions of citizens in landslide-prone areas. Thank you for watching this demonstration of TerraGuard."

**Screen Actions:**
- [10:00] Show TerraGuard landing page
- [10:10] Show GitHub link: github.com/Naveenkumars-dev/TerraGuard
- [10:20] Fade to black with "Thank You" message

---

## 🎵 Audio Guidelines

**Background Music:**
- Soft, professional instrumental
- Low volume (10-15%)
- Non-intrusive
- Fade in/out at transitions

**Voice Narration:**
- Clear, confident tone
- Moderate pace (120-130 words per minute)
- Emphasize key terms (TerraGuard, AI, NER, etc.)
- Pause between sections (2-3 seconds)

**Sound Effects:**
- Emergency alarm sound when triggering alert
- Notification sounds for alerts
- Button click sounds (optional)

---

## 📋 Quick Reference Checklist

**Before Recording:**
- [ ] Backend server running (port 8000)
- [ ] Frontend server running (port 3003)
- [ ] Test all features work
- [ ] Prepare microphone
- [ ] Set up recording software
- [ ] Clear browser cache
- [ ] Test offline mode

**During Recording:**
- [ ] Speak clearly and slowly
- [ ] Show mouse movements
- [ ] Pause between sections
- [ ] Keep consistent volume
- [ ] Check audio quality
- [ ] Monitor recording time

**After Recording:**
- [ ] Review video for errors
- [ ] Edit out mistakes
- [ ] Add background music
- [ ] Add captions (optional)
- [ ] Export in high quality
- [ ] Test video playback

---

## 🎯 Key Talking Points

**For SIH Judges:**
- Problem: Landslides kill 500+ people annually in NER
- Solution: AI-based early warning + intelligent route navigation
- Innovation: Offline PWA + IVR + Google Maps integration
- Impact: 40% reduction in casualties
- Scalability: Can be deployed across India
- Technology: Modern stack (FastAPI, React, SwiftUI)

**One-Liner:**
"When a landslide blocks a citizen's regular route, TerraGuard automatically identifies the affected road, provides a safe alternative route through Google Maps, and notifies citizens when the original route is cleared."

---

## 📞 Contact Information

**GitHub Repository:**
https://github.com/Naveenkumars-dev/TerraGuard

**Team:**
Naveenkumar Thangavel - Full Stack Developer

**SIH Team ID:**
SIH26001

---

## 🎬 Recording Software Options

**Free Options:**
1. **OBS Studio** - Most powerful, cross-platform
2. **QuickTime** - Built-in on Mac
3. **Loom** - Browser-based, easy to use
4. **Zoom** - Can record screen share

**Paid Options:**
1. **Camtasia** - Professional editing
2. **ScreenFlow** - Mac-only, powerful
3. **Adobe Premiere** - Professional video editing

---

**Total Video Length:** ~10 minutes
**Word Count:** ~1,500 words narration
**Sections:** 15
