import SwiftUI

/// A rounded card holding a list of rows with dividers between them.
///
/// Short lists draw their rows directly so the card hugs its content; once
/// there are more than `maxRowsWithoutScroll` items the rows go into a
/// ScrollView of `scrollHeight` points. An empty list shows `emptyMessage`.
/// The optional header sits above a divider and stays put while rows scroll.
public struct TableCard<Item: Identifiable, Header: View, Row: View>: View {
    let items: [Item]
    let emptyMessage: String
    let maxRowsWithoutScroll: Int
    let scrollHeight: CGFloat
    let dividerInset: CGFloat
    let header: Header?
    let row: (Item) -> Row

    public init(_ items: [Item],
                emptyMessage: String,
                maxRowsWithoutScroll: Int,
                scrollHeight: CGFloat,
                dividerInset: CGFloat = 0,
                @ViewBuilder header: () -> Header,
                @ViewBuilder row: @escaping (Item) -> Row) {
        self.items = items
        self.emptyMessage = emptyMessage
        self.maxRowsWithoutScroll = maxRowsWithoutScroll
        self.scrollHeight = scrollHeight
        self.dividerInset = dividerInset
        self.header = header()
        self.row = row
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let header {
                header
                Divider().overlay(Theme.divider)
            }
            if items.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
            } else if items.count <= maxRowsWithoutScroll {
                VStack(spacing: 0) { rows }
                    .fixedSize(horizontal: false, vertical: true)   // rows keep their full height, e.g. two-line text
            } else {
                // Long lists only build the rows that are on screen.
                ScrollView { LazyVStack(spacing: 0) { rows } }.frame(height: scrollHeight)
            }
        }
        .background(Theme.cardBG, in: RoundedRectangle(cornerRadius: 9))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Theme.fieldBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    private var rows: some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
            row(item)
            if i < items.count - 1 {
                Divider().overlay(Theme.divider).padding(.leading, dividerInset)
            }
        }
    }
}

extension TableCard where Header == EmptyView {
    /// A card with no header row.
    public init(_ items: [Item],
                emptyMessage: String,
                maxRowsWithoutScroll: Int,
                scrollHeight: CGFloat,
                dividerInset: CGFloat = 0,
                @ViewBuilder row: @escaping (Item) -> Row) {
        self.items = items
        self.emptyMessage = emptyMessage
        self.maxRowsWithoutScroll = maxRowsWithoutScroll
        self.scrollHeight = scrollHeight
        self.dividerInset = dividerInset
        self.header = nil
        self.row = row
    }
}

extension View {
    /// Tints a table row ember while the pointer is over it and makes the
    /// whole row clickable. `hover` is updated so the row can reveal buttons.
    public func tableRowHover(_ hover: Binding<Bool>) -> some View {
        background(hover.wrappedValue ? Theme.emberTint : Color.clear)
            .contentShape(Rectangle())
            .onHover { hover.wrappedValue = $0 }
    }
}
