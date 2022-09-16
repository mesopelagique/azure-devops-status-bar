import Cocoa
import Combine
import ComposableArchitecture
import QuatreD

public final class View {

    public init(store: Store<State, Action>, imageURL: URL?) {
        self.store = store
        self.viewStore = .init(store.scope(state: ViewState.state))
        item.menu = menu
        viewStore.$state
            .sink(receiveValue: { [unowned self] in self.update(viewState: $0) })
            .store(in: &cancellables)

        if let url = imageURL {
            item.button?.image = NSImage(contentsOf: url)
            item.button?.image?.isTemplate = true
        } else {
            item.button?.image = NSImage(systemSymbolName: "questionmark.square.dashed", accessibilityDescription: nil)
        }
    }

    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()

    private let store: Store<State, Action>
    private let viewStore: ViewStore<ViewState, Action>
    private var cancellables = Set<AnyCancellable>()

    private func update(viewState: ViewState) {
        menu.items = []
        if !viewState.urls.isEmpty {
            let urls = viewState.urls
            menu.items.append(contentsOf: urls.flatMap { item in
                return [menuItem(for: item), shiftMenuItem(for: item)]
            }
            )
            menu.items.append(contentsOf: urls.map(shiftMenuItem(for:)))
            menu.items.append(.separator())
        }
        menu.items.append(MenuItem(title: "Settings", action: { [weak self] in
            self?.viewStore.send(.settings)
        }))
        menu.items.append(MenuItem(title: "Refresh", action: { [weak self] in
            self?.viewStore.send(.refresh)
        }))
  
        menu.items.append(.separator())
        menu.items.append(MenuItem(title: "Quit", action: { [weak self] in
            self?.viewStore.send(.quit)
        }))
    }

    private func menuItem(for item: WorkItemFull) -> NSMenuItem {
        let menuItem = MenuItem(title:"\(item.id) \(item.title)", action: { [weak self] in
            if let url = item.htmlURL {
                self?.viewStore.send(.openURL(url: url))
            }
        })
        menuItem.image = item.stateImage

        return menuItem
    }

    private func shiftMenuItem(for item: WorkItemFull) -> NSMenuItem {
        let menuItem = MenuItem(title:"Copy azure:\(item.id) to pasteboard", action: {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            if !pasteboard.setString("azure:\(item.id)", forType: .string) {
                print("not able to set in pasteboard")
            }
        })
        menuItem.isAlternate = true
        menuItem.keyEquivalentModifierMask = .shift
        menuItem.image = item.stateImage

        return menuItem
    }

}

public extension WorkItemFull {

    var stateImage: NSImage? {
        switch state {
        case "Active":
            return .active
        case "Proposed":
            return .proposed
        case "Closed":
            return.closed
        case "Rejected":
            return .rejected
        case "Resolved":
            return .resolved
        case "Pending":
            return .pending
        case "Planned":
            return .planned
        case "In Progress":
            return .inProgress
        case "To do":
            return .toDo
        default:
            return .circleFill
        }
    } 
}

extension NSImage {
    func image(with tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }

        let image = self.copy() as! NSImage
        image.lockFocus()

        tintColor.set()

        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)

        image.unlockFocus()
        image.isTemplate = false

        return image
    }
}

extension NSColor {
    static let proposed: NSColor = NSColor(calibratedRed: 178/255.0, green: 178/255.0, blue: 178/255.0, alpha: 1)
    static let active: NSColor = NSColor(calibratedRed: 0, green: 122/255.0, blue: 204/255.0, alpha: 1)
    static let closed: NSColor = NSColor(calibratedRed: 178/255.0, green: 178, blue: 178, alpha: 1)
    static let rejected: NSColor = NSColor(calibratedRed: 86/255.0, green: 136/255.0, blue: 223/255.0, alpha: 1)
    static let resolved: NSColor = NSColor(calibratedRed: 255/255.0, green: 158/255.0, blue: 0/255.0, alpha: 1)
    static let pending: NSColor = NSColor(calibratedRed: 242/255.0, green: 102/255.0, blue: 186/255.0, alpha: 1)
    static let planned: NSColor = NSColor(calibratedRed: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1)
    static let inProgress: NSColor = NSColor(calibratedRed: 86/255.0, green: 136/255.0, blue: 223/255.0, alpha: 1)
    static let toDo: NSColor = NSColor(calibratedRed: 214/255.0, green: 237/255.0, blue: 236/255.0, alpha: 1)
}

extension NSImage {
    static let circleFill = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)
    static let circle = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)
    static let proposed: NSImage? = circleFill?.image(with: .proposed)
    static let active: NSImage? = circleFill?.image(with: .active)
    static let closed: NSImage? = circleFill?.image(with: .closed)
    static let rejected: NSImage? = circle?.image(with: .rejected)
    static let resolved: NSImage? = circle?.image(with: .resolved)
    static let pending: NSImage? = circleFill?.image(with: .pending)
    static let planned: NSImage? = circleFill?.image(with: .planned)
    static let inProgress: NSImage? = circleFill?.image(with: .inProgress)
    static let toDo: NSImage? = circleFill?.image(with: .toDo)
}
