import Foundation
import Combine
import Combine
import Cocoa
import Prephirences

public struct Favorites {
    public typealias Value = [WorkItemFull]

    public static var orga = "4dimension"
    public static var project = "4D"
    public static var version = "7.1-preview.2"
    public static var apiURL: String {
        return "https://dev.azure.com/\(orga)/\(project)/_apis/wit/wiql/?api-version=\(version)"
    }
    public static var witql = "Select [System.Title], [System.Id], [System.State] From WorkItems Where [State] <> 'Rejected' AND [State] <> 'Closed' AND [State] <> 'Removed' AND [System.AssignedTo] = @me"

    public static var patAuth: String {
        return (KeychainPreferences.sharedInstance.string(forKey: "azurepat") ?? "").toBase64()
    }

    public static func get() -> AnyPublisher<Value, Never> {
        // XXX replace all by async, await, but Reducer api do not support it
        return Future { promise in

            var urlRequest = URLRequest(url: URL(string: apiURL)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = ("{\"query\": \"\(witql)\"}").data(using: .utf8)
            urlRequest.allHTTPHeaderFields = ["Authorization": "Basic \(patAuth)", "Content-Type": "application/json"]

            URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                DispatchQueue.global(qos: .userInitiated).async {
                    if error != nil {
                        promise(.success([])) // error
                        return
                    }
                    guard let data = data else {
                        promise(.success([]))  // error
                        return
                    }
                    print(String(data: data, encoding: .utf8) ?? "error")

                    guard let queryResult: QueryResult = try? JSONDecoder().decode(QueryResult.self, from: data) else {
                        promise(.success([]))  // error
                        return
                    }

                    var workItems: Value = []
                    let urls = queryResult.workItems.compactMap({URL(string: $0.url)})
                    for url in urls {
                        let semaphore = DispatchSemaphore(value: 0)

                        var urlRequest = URLRequest(url: url)
                        urlRequest.httpMethod = "GET"
                        urlRequest.allHTTPHeaderFields = ["Authorization": "Basic \(patAuth)", "Content-Type": "application/json"]

                        DispatchQueue.global(qos: .background).async {
                            URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                                if let data = data, let workItem: WorkItemFull = try? JSONDecoder().decode(WorkItemFull.self, from: data) {
                                    workItems.append(workItem)
                                }
                                semaphore.signal()
                            }.resume()
                        }

                        semaphore.wait()
                    }


                    promise(.success(workItems))
                }

            }.resume()
        }.eraseToAnyPublisher()
    }

    public static func settings() -> AnyPublisher<Void, Never> {

        return Future { promise in

            let msg = NSAlert()
            msg.addButton(withTitle: "OK")      // 1st button
            msg.addButton(withTitle: "Cancel")  // 2nd button
            msg.messageText = "Enter mail:personal accesstoken"
            msg.informativeText = "pat: could be created in your user settings"

            let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            txt.stringValue = ""

            msg.accessoryView = txt
            let response: NSApplication.ModalResponse = msg.runModal()

            if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                KeychainPreferences.sharedInstance.set( txt.stringValue, forKey: "azurepat")
            }

            promise(.success(()))

        }.eraseToAnyPublisher()
    }
}

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
