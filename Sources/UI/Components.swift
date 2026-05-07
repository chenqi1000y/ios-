import SwiftUI
import UIKit

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.white)
            .padding(.vertical, 16)
            .background(AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.deep)
            .padding(.vertical, 16)
            .background(AppTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Color.red)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct EmptyStateCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.muted)
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.deep)
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct AsyncCardImage: View {
    let url: URL?
    let previewImage: UIImage?
    let height: CGFloat

    var body: some View {
        Group {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
            } else if let url, url.isFileURL, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder("图片加载失败")
                    default:
                        ProgressView()
                    }
                }
            } else {
                placeholder("等待图片")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(AppTheme.soft)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func placeholder(_ title: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "house.lodge")
                .font(.system(size: 30))
            Text(title)
                .font(.footnote)
        }
        .foregroundStyle(AppTheme.muted)
    }
}

struct AsyncThumbnail: View {
    let url: URL?

    var body: some View {
        AsyncCardImage(url: url, previewImage: nil, height: 64)
            .frame(width: 64, height: 64)
    }
}

struct FlexibleTagWrap: View {
    let items: [String]
    let selected: [String]
    let action: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button {
                    action(item)
                } label: {
                    Text(item)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(selected.contains(item) ? Color.white : AppTheme.deep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selected.contains(item) ? AppTheme.deep : AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.black.opacity(selected.contains(item) ? 0 : 0.06), lineWidth: 1)
                        )
                }
            }
        }
    }
}
