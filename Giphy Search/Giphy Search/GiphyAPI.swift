import Foundation

enum GiphyAPIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case emptyAPIKey
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."

        case .invalidResponse:
            return "The server returned an invalid response."

        case .httpError(let statusCode):
            return "GIPHY returned HTTP error \(statusCode)."

        case .decodingError:
            return "Failed to decode GIPHY response."

        case .emptyAPIKey:
            return "GIPHY API key is missing."

        case .requestFailed(let message):
            return message
        }
    }
}

protocol GiphyAPIProtocol {
    func search(
        query: String,
        offset: Int,
        limit: Int
    ) async throws -> GiphyResponse

    func trending(
        offset: Int,
        limit: Int
    ) async throws -> GiphyResponse
}

final class GiphyAPI: GiphyAPIProtocol {

    private let session: URLSession
    private let apiKey: String

    private let baseURL = "https://api.giphy.com/v1/gifs"

    init(
        session: URLSession = .shared,
        apiKey: String = AppConfiguration.giphyAPIKey
    ) {
        self.session = session
        self.apiKey = apiKey
    }

    func search(
        query: String,
        offset: Int,
        limit: Int
    ) async throws -> GiphyResponse {

        try await performRequest(
            endpoint: "search",
            parameters: [
                "q": query,
                "offset": String(offset),
                "limit": String(limit),
                "rating": "pg-13",
                "lang": "en"
            ]
        )
    }

    func trending(
        offset: Int,
        limit: Int
    ) async throws -> GiphyResponse {

        try await performRequest(
            endpoint: "trending",
            parameters: [
                "offset": String(offset),
                "limit": String(limit),
                "rating": "pg-13"
            ]
        )
    }

    private func performRequest(
        endpoint: String,
        parameters: [String: String]
    ) async throws -> GiphyResponse {

        guard !apiKey.isEmpty,
              apiKey != "YOUR_GIPHY_API_KEY"
        else {
            throw GiphyAPIError.emptyAPIKey
        }

        guard var components = URLComponents(
            string: "\(baseURL)/\(endpoint)"
        ) else {
            throw GiphyAPIError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        queryItems.append(
            contentsOf: parameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        )

        components.queryItems = queryItems

        guard let url = components.url else {
            throw GiphyAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw GiphyAPIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw GiphyAPIError.httpError(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode(
                    GiphyResponse.self,
                    from: data
                )
            } catch {
                throw GiphyAPIError.decodingError
            }

        } catch let error as GiphyAPIError {
            throw error

        } catch is CancellationError {
            throw CancellationError()

        } catch {
            throw GiphyAPIError.requestFailed(
                error.localizedDescription
            )
        }
    }
}
