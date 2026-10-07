import SwiftUI

struct GIFCard: View {

    let gif: GiphyGIF

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            if let imageURL = gif.images.fixedWidthSmall?.url {
                GiphyGIFView(url: imageURL)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.0, contentMode: .fill)
                    .clipped()
            } else if let imageURL = gif.images.fixedHeightSmall?.url {
                GiphyGIFView(url: imageURL)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.0, contentMode: .fill)
                    .clipped()
            } else {
                Color.secondary.opacity(0.15)

                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.7)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(
                gif.title.isEmpty
                    ? "GIF"
                    : gif.title
            )
            .font(.caption)
            .foregroundStyle(.white)
            .lineLimit(2)
            .padding(8)
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
        .contentShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }
}
