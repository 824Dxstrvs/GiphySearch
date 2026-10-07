import SwiftUI

struct LoadingFooter: View {

    var body: some View {
        HStack {
            Spacer()

            ProgressView()
                .padding()

            Spacer()
        }
    }
}
