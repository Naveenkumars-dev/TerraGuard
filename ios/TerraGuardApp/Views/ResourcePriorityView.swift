import SwiftUI

struct ResourcePriorityView: View {
    @StateObject private var apiService = APIService.shared
    
    @State private var allocations: [ResourceAllocation] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header Overview
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("AI Emergency Resource Prioritization")
                                .font(.headline)
                        }
                        
                        Text("Optimizes limited NDRF/SDRF rescue teams, ambulances, and heavy machinery based on multi-factor vulnerability & time criticality.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)

                    if isLoading {
                        ProgressView("Computing Priority Matrix & Dispatch Rationale...")
                            .padding()
                    } else {
                        VStack(spacing: 16) {
                            ForEach(Array(allocations.enumerated()), id: \.element.id) { index, alloc in
                                PriorityIncidentCard(rank: index + 1, allocation: alloc)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Resource Dispatch")
            .onAppear(perform: loadAllocations)
        }
    }
    
    private func loadAllocations() {
        isLoading = true
        Task {
            do {
                allocations = try await apiService.fetchResourceAllocations()
                isLoading = false
            } catch {
                errorMessage = "Failed to load allocations: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

struct PriorityIncidentCard: View {
    let rank: Int
    let allocation: ResourceAllocation
    
    @State private var isExpanded: Bool = false

    var rankColor: Color {
        switch rank {
        case 1: return .red
        case 2: return .orange
        default: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("PRIORITY #\(rank)")
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rankColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)

                Text("Score: \(String(format: "%.1f", allocation.priority_score))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)

                Spacer()

                BadgeView(text: allocation.status, color: .green)
            }

            Text(allocation.incident_name)
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("People at Risk")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(allocation.people_at_risk)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Severity")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(allocation.severity_level)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Rescue Window")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(allocation.time_criticality_minutes) min")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }

            Divider()

            // Assigned Unit Badges
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "person.3.sequence.fill")
                        .foregroundColor(.blue)
                    Text("Assigned Team:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(allocation.assigned_team)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }

                HStack {
                    Image(systemName: "cross.vial.fill")
                        .foregroundColor(.green)
                    Text("Assigned Vehicle:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(allocation.assigned_vehicle)
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
            }

            // Explainable AI Rationale Box
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                    Text("Explainable AI (XAI) Rationale")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Text(allocation.rationale)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
            }
            .padding(10)
            .background(Color.purple.opacity(0.08))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
