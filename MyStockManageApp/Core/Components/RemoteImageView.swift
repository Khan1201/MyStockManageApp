import SwiftUI

struct RemoteImageView<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    private let placeholder: () -> Placeholder

    init(
        url: URL?,
        contentMode: ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .empty, .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
    }
}
