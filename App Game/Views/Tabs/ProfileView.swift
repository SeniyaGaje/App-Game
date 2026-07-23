import SwiftUI
import PhotosUI
import UIKit

struct ProfileView: View {
    @AppStorage("playerName") private var playerName: String = "Player 1"
    @AppStorage("playerJoinDate") private var joinDateRaw: Double = Date().timeIntervalSince1970
    @AppStorage("playerAvatar") private var playerAvatar: String = "person.crop.circle.fill"
    @AppStorage("playerProfileImageData") private var profileImageData: Data = Data()

    @State private var selectedPhoto: PhotosPickerItem?
    
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
                        VStack(spacing: 12) {
                            ProfileAvatarImage(
                                imageData: profileImageData,
                                systemName: playerAvatar,
                                size: 112
                            )

                            HStack(spacing: 12) {
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    Label(
                                        profileImageData.isEmpty ? "Choose Photo" : "Change Photo",
                                        systemImage: "photo.on.rectangle"
                                    )
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .background(.purple.opacity(0.55), in: Capsule())
                                }

                                if !profileImageData.isEmpty {
                                    Button {
                                        profileImageData = Data()
                                        selectedPhoto = nil
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.red)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 9)
                                            .background(.white.opacity(0.07), in: Capsule())
                                    }
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(avatars, id: \.self) { avatar in
                                        Button {
                                            playerAvatar = avatar
                                            profileImageData = Data()
                                            selectedPhoto = nil
                                        } label: {
                                            Image(systemName: avatar)
                                                .font(.title)
                                                .foregroundStyle(
                                                    playerAvatar == avatar && profileImageData.isEmpty
                                                        ? .white
                                                        : .white.opacity(0.3)
                                                )
                                                .padding(12)
                                                .background(
                                                    Circle()
                                                        .fill(
                                                            playerAvatar == avatar && profileImageData.isEmpty
                                                                ? .purple.opacity(0.5)
                                                                : .white.opacity(0.05)
                                                        )
                                                )
                                                .overlay(
                                                    Circle()
                                                        .stroke(
                                                            playerAvatar == avatar && profileImageData.isEmpty
                                                                ? .purple
                                                                : .clear,
                                                            lineWidth: 2
                                                        )
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 10)
                        }
                        
                        // Name & Join Date
                        VStack(spacing: 6) {
                            HStack(alignment: .center, spacing: 8) {
                                TextField("Enter your name", text: $playerName)
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .fixedSize()
                                
                                Image(systemName: "pencil")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            
                            Text("Member since \(Date(timeIntervalSince1970: joinDateRaw).formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(.horizontal)
                        
                        // Dynamic Stats Grid
                        let sessions = StatsVM.shared.sessions
                        let totalGames = sessions.count
                        let bestScore = sessions.map(\.score).max() ?? 0
                        
                        let favoriteGame: String = {
                            if sessions.isEmpty { return "None Yet" }
                            let counts = Dictionary(grouping: sessions, by: { $0.mode }).mapValues { $0.count }
                            let best = counts.max { $0.value < $1.value }
                            return best?.key.rawValue ?? "None"
                        }()
                        
                        let playerRank: String = {
                            switch totalGames {
                            case 0..<5: return "Rookie"
                            case 5..<15: return "Challenger"
                            case 15..<30: return "Veteran"
                            case 30..<50: return "Master"
                            default: return "Legend"
                            }
                        }()
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ProfileStatCard(title: "Rank", value: playerRank, icon: "crown.fill", color: .yellow)
                            ProfileStatCard(title: "Top Game", value: favoriteGame, icon: "flame.fill", color: .red)
                            ProfileStatCard(title: "Games Played", value: "\(totalGames)", icon: "gamecontroller.fill", color: .green)
                            ProfileStatCard(title: "Best Score", value: "\(bestScore)", icon: "star.fill", color: .orange)
                        }
                        .padding(.horizontal, 20)
                        
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .task(id: selectedPhoto) {
                guard let selectedPhoto,
                      let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                      let resizedData = resizedProfileImageData(from: data) else {
                    return
                }

                profileImageData = resizedData
            }
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

    private func resizedProfileImageData(from data: Data) -> Data? {
        guard let sourceImage = UIImage(data: data) else { return nil }

        let maximumDimension: CGFloat = 600
        let sourceSize = sourceImage.size
        let scale = min(
            1,
            maximumDimension / max(sourceSize.width, sourceSize.height)
        )
        let targetSize = CGSize(
            width: max(1, sourceSize.width * scale),
            height: max(1, sourceSize.height * scale)
        )
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resizedImage.jpegData(compressionQuality: 0.78)
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(color)
                .padding(14)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
}
