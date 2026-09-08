# TerraGuard iOS App - Xcode Setup Guide

This guide provides step-by-step instructions to set up and run the TerraGuard iOS application on a Mac with Xcode.

---

## Prerequisites

- **Mac** with macOS 12.0 (Monterey) or later
- **Xcode** 14.0 or later (download from Mac App Store)
- **Apple Developer Account** (free tier is sufficient for simulator testing)
- **iOS 15.0+** deployment target

---

## Step 1: Install Xcode

### Option A: From Mac App Store (Recommended)
1. Open Mac App Store
2. Search for "Xcode"
3. Click "Get" or "Install" (approximately 10-15 GB download)
4. Wait for installation to complete

### Option B: Command Line Installation
```bash
# Install Xcode Command Line Tools first
xcode-select --install

# Then install Xcode from Mac App Store as above
```

### Verify Installation
```bash
xcodebuild -version
# Should output: Xcode 14.x / 15.x
```

---

## Step 2: Create New Xcode Project

1. **Launch Xcode** from Applications folder
2. **Create New Project**:
   - File → New → Project (or Cmd+Shift+N)
   - Select **iOS** tab
   - Choose **App** template
   - Click "Next"

3. **Configure Project Settings**:
   - **Product Name**: `TerraGuardApp`
   - **Team**: Select your Apple ID (or "None" for development)
   - **Organization Identifier**: `com.terraguard` (or your own)
   - **Bundle Identifier**: Auto-generated as `com.terraguard.TerraGuardApp`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: **None**
   - **Include Tests**: Uncheck (for prototype simplicity)
   - Click "Next"

4. **Save Location**:
   - Choose a location (e.g., `/Users/YourName/Projects/`)
   - Uncheck "Create Git repository" (optional)
   - Click "Create"

---

## Step 3: Add Existing Source Files

### Delete Default Files
1. In Xcode Project Navigator (left sidebar):
   - Delete `ContentView.swift` (Move to Trash)
   - Delete `TerraGuardAppApp.swift` (Move to Trash)

### Add Project Structure
1. Right-click on `TerraGuardApp` folder in Project Navigator
2. Select **Add Files to "TerraGuardApp"...**
3. Navigate to: `/Users/naveenkumarthangavel/Downloads/SIH/ios/TerraGuardApp/`
4. **Important Settings**:
   - ✅ Uncheck "Copy items if needed" (we want references)
   - ✅ Check "Create folder references"
   - ✅ Check "Add to targets: TerraGuardApp"
5. Click "Add"

### Verify File Structure
Your Project Navigator should now show:
```
TerraGuardApp
├── TerraGuardApp.swift
├── Models/
│   ├── CitizenUser.swift
│   └── CoordinationModels.swift
├── Services/
│   └── APIService.swift
└── Views/
    ├── DashboardView.swift
    ├── AlertsView.swift
    ├── RoadIntelligenceView.swift
    ├── ShelterResourceView.swift
    ├── EmergencyCommunicationView.swift
    ├── MainTabView.swift
    └── (other existing views)
```

---

## Step 4: Configure Build Settings

### Deployment Target
1. Click on project root in Project Navigator
2. Select **TerraGuardApp** target
3. **General** tab:
   - **Deployment Target**: Set to **iOS 15.0** or later
   - **Devices**: iPhone

### Signing & Capabilities
1. In **Signing & Capabilities** tab:
   - **Team**: Select your Apple ID
   - **Signing Certificate**: Should auto-generate
   - If errors appear, click "Try Automatically"

### Required Permissions (Optional)
If you want to use location features in the future, add to `Info.plist`:

1. Select `Info.plist` in Project Navigator
2. Right-click → Open As → Property List
3. Add these keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>TerraGuard needs location access for emergency alerts and shelter routing</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>TerraGuard needs location access for emergency alerts even when app is in background</string>
```

---

## Step 5: Build the Project

### Select Target Device
1. In Xcode toolbar (top), click device selector:
   - **For Simulator**: Choose "iPhone 15 Pro" or similar
   - **For Physical Device**: Connect iPhone via USB, select your device

### Build and Run
1. Press **Cmd+R** or click Play button in toolbar
2. Xcode will:
   - Build the project (first build takes 1-2 minutes)
   - Launch simulator (if selected)
   - Install and run the app

### Troubleshooting Build Errors

**Error: "No such module 'SwiftUI'"**
- Ensure iOS deployment target is 15.0+
- Clean build folder: Cmd+Shift+K
- Rebuild: Cmd+B

**Error: "Cannot find type 'MainTabView' in scope"**
- Verify all View files are added to target
- Check that files are not in "Compile Sources" with red icons
- Clean and rebuild

**Error: "Signing for "TerraGuardApp" requires a development team"**
- Go to Signing & Capabilities
- Select your Apple ID in Team dropdown
- Click "Try Automatically"

---

## Step 6: Test the App Features

Once the app launches, you should see 5 tab items:

### 1. 🏠 Dashboard
- Overview of current risk status
- Emergency response flow visualization
- Quick action buttons

### 2. 🚨 Alerts
- Click "Simulate Landslide Alert" to test
- See emergency alarm card with location, risk level, severity
- Click "Acknowledge Alert" to proceed
- Choose "I AM SAFE" or "I NEED HELP"
- View Rescue Dashboard with statistics

### 3. 🚧 Road Intel
- Click "Start AI Analysis"
- Watch multi-source verification (CCTV, Rainfall, Citizen Reports, Remote Data)
- See AI verification results with blockage confidence
- View evacuation routes with status indicators

### 4. 🏠 Shelter
- View smart shelter allocation
- See capacity, distance, and road status
- View resource allocation (Water, Food, Medical, Blankets)
- See AI priority recommendations

### 5. 📡 Emergency
- Toggle between Online/Offline mode
- See network status changes
- Click "Show Button Phone Message" for simulation
- View RF gateway architecture diagram

---

## Step 7: Run on Physical Device (Optional)

### Enable Developer Mode on iPhone
1. iPhone Settings → Privacy & Security → Developer Mode
2. Toggle ON (requires restart)

### Connect Device
1. Connect iPhone to Mac via USB
2. On iPhone: Trust this computer?
3. In Xcode: Select your iPhone from device dropdown
4. Press Cmd+R to build and run

### Troubleshooting Device Issues

**"Could not launch app" error**
- Check iPhone is unlocked
- Verify developer certificate is valid
- Try: Xcode → Window → Devices and Simulators → Delete device → Reconnect

**"Untrusted Developer" on iPhone**
- iPhone Settings → General → VPN & Device Management
- Find your Apple ID → Trust

---

## Step 8: Archive for Distribution (Optional)

For App Store submission or TestFlight:

1. **Product → Archive** (Cmd+Shift+B)
2. Wait for archive to complete
3. Organizer window opens automatically
4. **Distribute App**:
   - Select distribution method (App Store, Ad Hoc, Enterprise)
   - Follow on-screen instructions

---

## Common Issues and Solutions

### Xcode Installation Issues
**Problem**: Xcode won't install from App Store
- **Solution**: Ensure macOS version is compatible (12.0+)
- Check available disk space (need 15+ GB free)

### Simulator Not Available
**Problem**: No simulators in device dropdown
- **Solution**: 
  - Xcode → Preferences → Components
  - Download iOS simulators (15.0+)
  - Or use physical device

### Build Performance
**Problem**: Slow build times
- **Solution**:
  - Close other apps
  - Use SSD for project location
  - Enable "Build Active Architecture Only" in Build Settings

### SwiftUI Preview Not Working
**Problem**: Canvas preview shows errors
- **Solution**:
  - Ensure iOS deployment target is 15.0+
  - Restart Xcode
  - Try building first (Cmd+B) before using preview

---

## Project File Locations

**Source Files Location**: `/Users/naveenkumarthangavel/Downloads/SIH/ios/TerraGuardApp/`

**Key Files to Copy**:
- `TerraGuardApp.swift` (main entry point)
- `Models/*.swift` (data models)
- `Services/*.swift` (API service)
- `Views/*.swift` (all SwiftUI views)

---

## Next Steps After Setup

1. **Test all 5 features** as described in Step 6
2. **Customize app icon** and launch screen
3. **Add backend API integration** (currently using mock data)
4. **Implement real location services** for GPS features
5. **Add push notification support** for emergency alerts
6. **Test on multiple device sizes** (iPhone SE, iPhone 15 Pro Max)

---

## Support Resources

- **Apple Developer Documentation**: https://developer.apple.com/documentation/
- **SwiftUI Tutorials**: https://developer.apple.com/tutorials/swiftui/
- **Xcode Help**: Help → Xcode Help within Xcode

---

## Quick Reference Commands

```bash
# Verify Xcode installation
xcodebuild -version

# Clean build folder
# In Xcode: Cmd+Shift+K

# Build project
# In Xcode: Cmd+B

# Run project
# In Xcode: Cmd+R

# Open Simulator
open -a Simulator

# List available simulators
xcrun simctl list devices

# Reset simulator content
xcrun simctl erase all
```

---

## Summary

This guide covers:
- ✅ Xcode installation
- ✅ Project creation
- ✅ Source file integration
- ✅ Build configuration
- ✅ Running on simulator and device
- ✅ Testing all 5 features
- ✅ Troubleshooting common issues

Follow these steps to set up the TerraGuard iOS app on your Mac with Xcode. The app is ready for SIH prototype demonstration with all 5 features implemented.
