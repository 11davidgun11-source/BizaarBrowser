import SwiftUI

struct BrowserToolbar: View {
    @ObservedObject var browserState: BrowserState

    var body: some View {
        HStack(spacing: 24) {
            Button(action: browserState.goBack) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .disabled(!browserState.canGoBack)

            Button(action: browserState.goForward) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(!browserState.canGoForward)

            Button(action: browserState.reload) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
            }

            Spacer()

            if !browserState.mediaDetector.detectedMedia.isEmpty {
                Text("\(browserState.mediaDetector.detectedMedia.count)")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.gold)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}
