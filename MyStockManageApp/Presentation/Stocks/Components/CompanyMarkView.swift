import SwiftUI

struct CompanyMarkView: View {
    let imageURL: URL?

    init(imageURL: URL?) {
        self.imageURL = imageURL
    }

    var body: some View {
        RemoteImageView(url: imageURL) {
            Color.clear
        }
        .frame(width: 38, height: 38)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}
