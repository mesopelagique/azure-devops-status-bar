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
            menu.items.append(contentsOf: urls.map(menuItem(for:)))
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
        MenuItem(title:"\(item.stateIcon) \(item.id) \(item.title)", action: { [weak self] in
            if let url = item.htmlURL {
                self?.viewStore.send(.openURL(url: url))
            }
        })
    }

}
