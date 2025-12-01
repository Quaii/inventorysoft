import SwiftUI

struct WidgetGrid<Content: View, Item: Identifiable & Equatable>: View {
    @Environment(\.theme) var theme

    let items: [Item]
    let isEditing: Bool
    let content: (Item) -> Content
    let onMove: ((IndexSet, Int) -> Void)?
    let onReorder: ((Item, Item) -> Void)?

    init(
        items: [Item],
        isEditing: Bool,
        @ViewBuilder content: @escaping (Item) -> Content,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        onReorder: ((Item, Item) -> Void)? = nil
    ) {
        self.items = items
        self.isEditing = isEditing
        self.content = content
        self.onMove = onMove
        self.onReorder = onReorder
    }

    // Grid Configuration
    #if os(macOS)
        private let columns = [
            GridItem(.adaptive(minimum: 350), spacing: 16)
        ]
    #else
        private let columns = [
            GridItem(.adaptive(minimum: 300), spacing: 16)
        ]
    #endif

    var body: some View {
        LazyVGrid(columns: columns, spacing: theme.layout.cardSpacing) {
            ForEach(items) { item in
                content(item)
                    .id(item.id)
                    // Drag and Drop for reordering
                    .onDrag {
                        if isEditing {
                            return NSItemProvider(object: "\(item.id)" as NSString)
                        } else {
                            return NSItemProvider()
                        }
                    }
                    .onDrop(
                        of: [.text],
                        delegate: WidgetDropDelegate(
                            item: item,
                            items: items,
                            onReorder: { from, to in
                                onReorder?(from, to)
                            }
                        ))
            }
        }
        .animation(.spring(), value: items)
    }
}

// Helper for Drag and Drop
struct WidgetDropDelegate<Item: Identifiable & Equatable>: DropDelegate {
    let item: Item
    let items: [Item]
    let onReorder: (Item, Item) -> Void

    func dropEntered(info: DropInfo) {
        // Simple reorder preview could go here
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }

        itemProvider.loadObject(ofClass: NSString.self) { (idString, error) in
            guard let idString = idString as? String else { return }

            DispatchQueue.main.async {
                if let sourceIndex = items.firstIndex(where: { "\($0.id)" == idString }),
                    let destinationIndex = items.firstIndex(of: item)
                {

                    if sourceIndex != destinationIndex {
                        let sourceItem = items[sourceIndex]
                        let destinationItem = items[destinationIndex]
                        onReorder(sourceItem, destinationItem)
                    }
                }
            }
        }
        return true
    }
}
