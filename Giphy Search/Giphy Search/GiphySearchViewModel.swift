import Foundation
import Observation

@MainActor
@Observable
final class GiphySearchViewModel {

    private(set) var gifs: [GiphyGIF] = []

    private(set) var isLoading = false
    private(set) var isLoadingMore = false

    private(set) var errorMessage: String?

    var searchText = ""

    private(set) var hasMorePages = true

    private let api: GiphyAPIProtocol

    private var searchTask: Task<Void, Never>?
    private var currentQuery = ""

    private var offset = 0

    private let pageSize = 25

    init(api: GiphyAPIProtocol) {
        self.api = api
    }

    deinit {
        searchTask?.cancel()
    }

    // Called from the TextField. The task is cancelled every time
    // the user changes the text, which gives us debounce behaviour.
    func searchTextDidChange() {
        searchTask?.cancel()

        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            gifs = []
            errorMessage = nil
            currentQuery = ""
            offset = 0
            hasMorePages = true
            return
        }

        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(
                    for: .milliseconds(400)
                )

                guard !Task.isCancelled else {
                    return
                }

                await self?.performNewSearch(query: query)

            } catch {
                // Cancellation is expected when the user types again.
            }
        }
    }

    func retry() {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return
        }

        searchTask?.cancel()

        searchTask = Task { [weak self] in
            await self?.performNewSearch(query: query)
        }
    }

    func loadMoreIfNeeded(currentItem: GiphyGIF) {
        guard currentItem.id == gifs.last?.id else {
            return
        }

        guard !isLoadingMore,
              !isLoading,
              hasMorePages
        else {
            return
        }

        Task {
            await loadNextPage()
        }
    }

    private func performNewSearch(query: String) async {
        currentQuery = query
        offset = 0
        hasMorePages = true
        errorMessage = nil
        gifs = []

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await api.search(
                query: query,
                offset: 0,
                limit: pageSize
            )

            guard query == currentQuery else {
                return
            }

            gifs = response.data
            offset = response.pagination.offset
                + response.pagination.count

            hasMorePages = !response.data.isEmpty
                && offset < response.pagination.totalCount

        } catch is CancellationError {
            // Expected when a newer search replaces the old one.
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadNextPage() async {
        guard !currentQuery.isEmpty else {
            return
        }

        isLoadingMore = true

        defer {
            isLoadingMore = false
        }

        do {
            let response = try await api.search(
                query: currentQuery,
                offset: offset,
                limit: pageSize
            )

            let existingIDs = Set(gifs.map(\.id))

            let newGIFs = response.data.filter {
                !existingIDs.contains($0.id)
            }

            gifs.append(contentsOf: newGIFs)

            offset = response.pagination.offset
                + response.pagination.count

            hasMorePages = !response.data.isEmpty
                && offset < response.pagination.totalCount

        } catch is CancellationError {
            // Ignore cancelled pagination requests.

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
