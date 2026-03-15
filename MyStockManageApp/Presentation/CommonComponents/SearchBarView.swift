import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: LocalizedStringResource
    let clearAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.55, green: 0.61, blue: 0.71))

            TextField("", text: $text, prompt: Text(placeholder))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.18, green: 0.22, blue: 0.32))

            if text.isEmpty == false {
                Button(action: clearAction) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.66, green: 0.71, blue: 0.80))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.94, green: 0.96, blue: 0.99))
        )
    }
}
