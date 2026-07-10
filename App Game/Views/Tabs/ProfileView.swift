import SwiftUI

struct ProfileView: View {
    @AppStorage("playerName") private var playerName: String = "Player 1"
    @AppStorage("playerJoinDate") private var joinDateRaw: Double = Date().timeIntervalSince1970
    @AppStorage("playerAvatar") private var playerAvatar: String = "person.crop.circle.fill"
    
    @Environment(\.dismiss) private var dismiss
    
    private let avatars = [
        "person.crop.circle.fill",
        "hare.fill",
        "tortoise.fill",
        "bird.fill",
        "flame.fill",
        "sparkles",
        "star.fill"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.08).ignoresSafeArea()
                
                // Background decoration
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 100, y: -200)
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // Avatar Picker
                        VStack {
                            Image(systemName: playerAvatar)
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(colors: [.purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .padding()
                                .background(.black.opacity(0.3), in: Circle())
                                .shadow(color: .purple.opacity(0.3), radius: 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(avatars, id: \.self) { avatar in
                                        Button {
                                            playerAvatar = avatar
                                        } label: {
                                            Image(systemName: avatar)
                                                .font(.title)
                                                .foregroundStyle(playerAvatar == avatar ? .white : .white.opacity(0.3))
                                                .padding(12)
                                                .background(
                                                    Circle()
                                                        .fill(playerAvatar == avatar ? .purple.opacity(0.5) : .white.opacity(0.05))
                                                )
                                                .overlay(
                                                    Circle()
                                                        .stroke(playerAvatar == avatar ? .purple : .clear, lineWidth: 2)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 10)
                        }
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PLAYER NAME")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.leading, 8)
                            
                            TextField("Enter your name", text: $playerName)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white)
                                .padding()
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.white.opacity(0.1), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        // Stats Overview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PLAYER STATS")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                StatRow(title: "Joined", value: Date(timeIntervalSince1970: joinDateRaw).formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                                Divider().background(.white.opacity(0.1)).padding(.leading, 40)
                                
                                // Calculate Favorite Game
                                let favoriteGame: String = {
                                    let sessions = StatsVM.shared.sessions
                                    if sessions.isEmpty { return "None Yet" }
                                    let counts = Dictionary(grouping: sessions, by: { $0.mode }).mapValues { $0.count }
                                    let best = counts.max { $0.value < $1.value }
                                    return best?.key.rawValue ?? "None Yet"
                                }()
                                
                                StatRow(title: "Favorite Game", value: favoriteGame, icon: "heart.fill")
                                Divider().background(.white.opacity(0.1)).padding(.leading, 40)
                                
                                // Calculate Player Rank based on games played
                                let playerRank: String = {
                                    let count = StatsVM.shared.sessions.count
                                    switch count {
                                    case 0..<5: return "Rookie"
                                    case 5..<15: return "Challenger"
                                    case 15..<30: return "Veteran"
                                    case 30..<50: return "Master"
                                    default: return "Legend"
                                    }
                                }()
                                
                                StatRow(title: "Player Rank", value: playerRank, icon: "trophy.fill")
                            }
                            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.white.opacity(0.1), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundStyle(.purple)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(.cyan)
                }
            }
        }
    }
}

private struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.purple.opacity(0.8))
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(.headline.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
