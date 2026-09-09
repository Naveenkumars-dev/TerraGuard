import SwiftUI

struct OfflineCacheView: View {
    @StateObject private var cacheService = OfflineCacheService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showSyncProgress = false
    @State private var syncProgress: Double = 0.0
    @State private var showClearCacheAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: cacheService.isOfflineMode ? "wifi.slash" : "wifi")
                                .foregroundColor(cacheService.isOfflineMode ? .orange : .green)
                                .font(.title2)
                            Text("Offline Cache")
                                .font(.headline)
                        }
                        
                        Text(cacheService.isOfflineMode ? "Offline mode - using cached data" : "Online mode - data sync available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Cache Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "internaldrive.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Cache Status")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Cache Size:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.2f MB", cacheService.cachedDataSummary.cacheSizeMB))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Last Sync:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(cacheService.getCacheAgeString())
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Cache Valid:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                HStack {
                                    Image(systemName: cacheService.isCacheValid() ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(cacheService.isCacheValid() ? .green : .red)
                                    Text(cacheService.isCacheValid() ? "Valid" : "Expired")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Cached Data Summary
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("Cached Data")
                                .font(.headline)
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            CacheDataItem(
                                icon: "house.fill",
                                title: "Shelters",
                                count: cacheService.cachedDataSummary.shelterCount,
                                color: .green
                            )
                            
                            CacheDataItem(
                                icon: "phone.fill",
                                title: "Emergency Contacts",
                                count: cacheService.cachedDataSummary.emergencyContactCount,
                                color: .red
                            )
                            
                            CacheDataItem(
                                icon: "road.lanes",
                                title: "Routes",
                                count: cacheService.cachedDataSummary.routeCount,
                                color: .blue
                            )
                            
                            CacheDataItem(
                                icon: "book.fill",
                                title: "Guides",
                                count: cacheService.cachedDataSummary.guideCount,
                                color: .orange
                            )
                            
                            CacheDataItem(
                                icon: "exclamationmark.triangle.fill",
                                title: "Risk Zones",
                                count: cacheService.cachedDataSummary.riskZoneCount,
                                color: .red
                            )
                            
                            CacheDataItem(
                                icon: "cross.case.fill",
                                title: "Medical Profile",
                                count: cacheService.cachedDataSummary.hasMedicalProfile ? 1 : 0,
                                color: .pink
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Sync Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Sync")
                            .font(.headline)
                        
                        Button(action: {
                            showSyncProgress = true
                            Task {
                                await cacheService.syncAllCriticalData()
                                showSyncProgress = false
                            }
                        }) {
                            HStack {
                                if showSyncProgress {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Sync All Critical Data")
                                }
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(showSyncProgress)
                        
                        if showSyncProgress {
                            ProgressView(value: syncProgress)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Emergency Guides (Offline Access)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Emergency Guides")
                                .font(.headline)
                            Spacer()
                            Text("Available Offline")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        let guides = EmergencyContentManager.shared.getPreloadedGuides()
                        VStack(spacing: 12) {
                            ForEach(guides) { guide in
                                EmergencyGuideCard(guide: guide)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Cache Management
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Cache Management")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                showClearCacheAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Clear All Cache")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                cacheService.syncAllCriticalData()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("Download Offline Maps")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Offline Tips
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Offline Tips")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(icon: "checkmark.circle", text: "Sync data when you have good internet connection")
                            TipRow(icon: "checkmark.circle", text: "Emergency guides are always available offline")
                            TipRow(icon: "checkmark.circle", text: "Cached shelters work without internet")
                            TipRow(icon: "checkmark.circle", text: "Location services work in offline mode")
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Offline Cache")
            .alert("Clear Cache", isPresented: $showClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    cacheService.clearCache()
                }
            } message: {
                Text("This will delete all cached data. Are you sure?")
            }
        }
    }
}

// MARK: - Cache Data Item
struct CacheDataItem: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Emergency Guide Card
struct EmergencyGuideCard: View {
    let guide: EmergencyGuide
    @State private var showFullGuide = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.circle.fill")
                    .foregroundColor(.blue)
                Text(guide.title)
                    .font(.headline)
                Spacer()
                Text(guide.category)
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
            }
            
            Text(guide.content)
                .font(.caption)
                .lineLimit(showFullGuide ? nil : 2)
                .foregroundColor(.secondary)
            
            if !showFullGuide {
                Button(action: { showFullGuide = true }) {
                    Text("Read More")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}