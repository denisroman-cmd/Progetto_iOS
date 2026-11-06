

import SwiftUI

struct MacroBar: View {
    let title: String
    let value: Double
    let target: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.caption)
                    .bold()
                Spacer()
                Text("\(Int(value)) / \(Int(target)) g")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: min(value, max(target, 1)), total: max(target, 1))
                .tint(color)
        }
    }
}

struct MacroBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(title).font(.caption2).foregroundColor(.gray)
            Text(value).font(.caption).bold().foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
