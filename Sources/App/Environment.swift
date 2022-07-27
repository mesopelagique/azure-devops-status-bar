import ComposableArchitecture
import Foundation
import Combine
import StatusBar
import QuatreD

public struct Environment {
    public init(
        fetchURLs: @escaping (() -> AnyPublisher<Favorites.Value, Never>),
        requestLogin: @escaping (() -> AnyPublisher<Action, Never>),
        urlOpener: @escaping (URL) -> Void,
        appTerminator: @escaping (Any?) -> Void,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.fetchURLs = fetchURLs
        self.requestLogin = requestLogin
        self.urlOpener = urlOpener
            self.appTerminator = appTerminator
            self.mainQueue = mainQueue
    }

    public var fetchURLs: (() -> AnyPublisher<Favorites.Value, Never>)
    public var requestLogin: (() -> AnyPublisher<Action, Never>)
    public var urlOpener: (URL) -> Void
    public var appTerminator: (Any?) -> Void
    public var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension Environment {
    var statusBar: StatusBar.Environemnt {
        .init(urlOpener: urlOpener, appTerminator: appTerminator)
    }
}
