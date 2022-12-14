import App
import Cocoa
import ComposableArchitecture
import Combine
import QuatreD
import Appify

Appify.run()

let app: NSApplication = .shared
let appView: View = .init(store: .init(
    initialState: .init(),
    reducer: reducer,
    environment: .init(
        fetchURLs: { Favorites.get() },
        requestLogin: { Favorites.settings().map({ return Action.fetchURLs }).eraseToAnyPublisher() },
        urlOpener: { NSWorkspace.shared.open($0) },
        appTerminator: app.terminate(_:),
        mainQueue: AnyScheduler(DispatchQueue.main)
    )
), imageURL: Bundle.module.url(forResource: "azure-devops", withExtension: "png"))

NSApp.setActivationPolicy(.accessory)
app.delegate = appView
app.run()
