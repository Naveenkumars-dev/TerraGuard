import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "exclamationmark.triangle.fill")
                }

            RoadIntelligenceView()
                .tabItem {
                    Label("Road Intel", systemImage: "road.lanes")
                }

            ShelterResourceView()
                .tabItem {
                    Label("Shelter", systemImage: "house.lodge.fill")
                }

            EmergencyCommunicationView()
                .tabItem {
                    Label("Emergency", systemImage: "antenna.radiowaves.left.and.right")
                }
        }
        .accentColor(.red)
    }
}
