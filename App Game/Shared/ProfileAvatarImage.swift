import SwiftUI
import UIKit

struct ProfileAvatarImage: View {
    let imageData: Data
    let systemName: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.35))

            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: systemName)
                    .font(.system(size: size * 0.52, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
        .shadow(color: .purple.opacity(0.3), radius: size * 0.14)
    }
}
