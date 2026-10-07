import SwiftUI

struct GIFDetailView: View {

    let gif: GiphyGIF

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                if let url = gif.images.original?.url {
                    GiphyGIFView(url: url)
                        .frame(
                            maxWidth: .infinity
                        )
                        .aspectRatio(
                            originalAspectRatio,
                            contentMode: .fit
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                        )
                }

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Text(
                        gif.title.isEmpty
                            ? "GIF"
                            : gif.title
                    )
                    .font(.title2)
                    .fontWeight(.semibold)

                    if let username = gif.username,
                       !username.isEmpty {

                        Label(
                            username,
                            systemImage: "person"
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }

                    if let giphyURL = gif.url {

                        Link(
                            "Open on GIPHY",
                            destination: giphyURL
                        )
                        .buttonStyle(
                            .borderedProminent
                        )
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("GIF")
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    private var originalAspectRatio: CGFloat {
        guard
            let widthString = gif.images.original?.width,
            let heightString = gif.images.original?.height,
            let width = Double(widthString),
            let height = Double(heightString),
            height > 0
        else {
            return 1
        }

        return CGFloat(width / height)
    }
}
