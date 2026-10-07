import Foundation
import Observation

@MainActor
@Observable
final class TrendingViewModel {

    private(set) var gifs: [GiphyGIF] = []

    private(set) var isLoading = false
    private(set) var isLoadingMore = false

    private(set) var errorMessage: String?

    private(set) var hasMorePages = true

    private let api: GiphyAPIProtocol

    private var offset = 0

    private let pageSize = 25

    init(api: GiphyAPIProtocol) {
        self.api = api
    }

    func loadInitialData() async {
        guard gifs.isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let response = try await api.trending(
                offset: 0,
                limit: pageSize
            )

            gifs = response.data

            offset = response.pagination.offset
                + response.pagination.count

            hasMorePages = !response.data.isEmpty
                && offset < response.pagination.totalCount

        } catch is CancellationError {
            // Nothing to do.

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func retry() {
        Task {
            await reload()
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

    private func reload() async {
        gifs = []
        offset = 0
        hasMorePages = true

        await loadInitialData()
    }

    private func loadNextPage() async {
        isLoadingMore = true

        defer {
            isLoadingMore = false
        }

        do {
            let response = try await api.trending(
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
            // Nothing to do.

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
