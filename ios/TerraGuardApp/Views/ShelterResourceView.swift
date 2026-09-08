import SwiftUI

struct ShelterResourceView: View {
    @State private var shelters: [Shelter] = []
    @State private var resources: [ResourceAllocation] = []
    @State private var affectedPeople: Int = 173
    @State private var showAllocation: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "house.lodge.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Shelter & Resources")
                                .font(.headline)
                        }
                        
                        Text("AI-powered smart shelter allocation and emergency resource distribution")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Smart Shelter Allocation
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("SMART SHELTER ALLOCATION")
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                        
                        HStack {
                            Text("Affected People:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(affectedPeople)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        
                        ForEach(shelters) { shelter in
                            ShelterCard(shelter: shelter)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Smart Resource Allocation
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "cube.box.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("SMART RESOURCE ALLOCATION")
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(resources) { resource in
                                ResourceCard(resource: resource)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "brain")
                                    .foregroundColor(.purple)
                                Text("🤖 AI PRIORITY")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.purple)
                                    Text("Medical supplies → Shelter A")
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.purple)
                                    Text("Water → Shelter B")
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.purple)
                                    Text("Food → Shelter A")
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.purple)
                                    Text("Blankets → Shelter A")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Shelter")
            .onAppear {
                loadShelters()
                loadResources()
            }
        }
    }
    
    private func loadShelters() {
        shelters = [
            Shelter(
                id: 1,
                name: "Shelter A",
                capacity: 100,
                current_occupancy: 87,
                distance_km: 2.1,
                road_status: "SAFE",
                is_recommended: true
            ),
            Shelter(
                id: 2,
                name: "Shelter B",
                capacity: 100,
                current_occupancy: 96,
                distance_km: 4.8,
                road_status: "BLOCKED",
                is_recommended: false
            )
        ]
    }
    
    private func loadResources() {
        resources = [
            ResourceAllocation(
                id: 1,
                resource_type: "💧 Water",
                availability_percentage: 87.0,
                priority_shelter: "Shelter B"
            ),
            ResourceAllocation(
                id: 2,
                resource_type: "🍱 Food",
                availability_percentage: 68.0,
                priority_shelter: "Shelter A"
            ),
            ResourceAllocation(
                id: 3,
                resource_type: "💊 Medical",
                availability_percentage: 94.0,
                priority_shelter: "Shelter A"
            ),
            ResourceAllocation(
                id: 4,
                resource_type: "🛏️ Blankets",
                availability_percentage: 51.0,
                priority_shelter: "Shelter A"
            )
        ]
    }
}

struct ShelterCard: View {
    let shelter: Shelter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(shelter.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if shelter.is_recommended {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("🤖 RECOMMENDED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Capacity")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(shelter.current_occupancy)/\(shelter.capacity)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Distance")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", shelter.distance_km)) km")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Road Status")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: shelter.road_status == "SAFE" ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(shelter.road_status == "SAFE" ? .green : .red)
                        Text(shelter.road_status)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(shelter.road_status == "SAFE" ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(shelter.is_recommended ? Color.purple.opacity(0.1) : Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(shelter.is_recommended ? Color.purple : Color.clear, lineWidth: 2)
        )
    }
}

struct ResourceCard: View {
    let resource: ResourceAllocation
    
    var availabilityColor: Color {
        if resource.availability_percentage >= 80 {
            return .green
        } else if resource.availability_percentage >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(resource.resource_type)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(String(format: "%.0f", resource.availability_percentage))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(availabilityColor)
            }
            
            ProgressView(value: resource.availability_percentage / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: availabilityColor))
            
            HStack {
                Text("Priority:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(resource.priority_shelter)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}
