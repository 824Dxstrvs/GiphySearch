import SwiftUI

@main
struct GiphySearchApp: App {

    private let api: GiphyAPIProtocol

    init() {
        api = GiphyAPI()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(api: api)
        }
    }
}
