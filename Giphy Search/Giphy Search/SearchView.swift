import SwiftUI

struct SearchView: View {

    @State private var viewModel: GiphySearchViewModel

    init(
        api: GiphyAPIProtocol
    ) {
        _viewModel = State(
            initialValue: GiphySearchViewModel(
                api: api
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.gifs.isEmpty {

                    ErrorView(
                        message: errorMessage,
                        retry: viewModel.retry
                    )

                } else if viewModel.searchText.isEmpty {

                    EmptySearchView()

                } else if viewModel.gifs.isEmpty {

                    ContentUnavailableView(
                        "No GIFs Found",
                        systemImage: "magnifyingglass",
                        description: Text(
                            "Try a different search term."
                        )
                    )

                } else {

                    ScrollView {
                        GIFGrid(
                            gifs: viewModel.gifs
                        ) { gif in
                            viewModel.loadMoreIfNeeded(
                                currentItem: gif
                            )
                        }

                        if viewModel.isLoadingMore {
                            LoadingFooter()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(
                    displayMode: .always
                ),
                prompt: "Search GIFs"
            )
            .onChange(
                of: viewModel.searchText
            ) { _, _ in
                viewModel.searchTextDidChange()
            }
        }
    }
}

private struct EmptySearchView: View {

    var body: some View {
        ContentUnavailableView(
            "Search GIPHY",
            systemImage: "magnifyingglass",
            description: Text(
                "Enter something like \"cats\", \"funny\" or \"hello\"."
            )
        )
    }
}
