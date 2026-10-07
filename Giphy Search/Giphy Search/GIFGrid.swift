import SwiftUI

struct GIFGrid: View {

    let gifs: [GiphyGIF]
    let onReachedEnd: (GiphyGIF) -> Void

    private let columns = [
        GridItem(
            .adaptive(minimum: 140),
            spacing: 10
        )
    ]

    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: 10
        ) {
            ForEach(gifs) { gif in

                NavigationLink {
                    GIFDetailView(gif: gif)
                } label: {
                    GIFCard(gif: gif)
                }
                .buttonStyle(.plain)
                .onAppear {
                    onReachedEnd(gif)
                }
            }
        }
        .padding(.horizontal)
    }
}
