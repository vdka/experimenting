
import UIKit
import JSON

struct Unsplash {

    static let base: String = "https://api.unsplash.com"

    enum Error: Swift.Error {
        case badResponse
    }

    static func request(_ endpoint: String, completion: @escaping (JSON?) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: Unsplash.base + endpoint) else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Authorization.current.header, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("v1", forHTTPHeaderField: "Accept-Version")

        return URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, _, _ in

            if let data = data {
                let json = try? JSON.Parser.parse(data)
                completion(json)
            } else {
                completion(nil)
            }
        })
    }

    static func random(count: Int, completion: @escaping (JSON?) -> Void) {
        Unsplash.request("/photos/random?count=\(count)&w=\(Int(UIScreen.main.bounds.width))", completion: completion)?.resume()
    }

    static func userPhotos(username: String, count: Int, completion: @escaping (JSON?) -> Void) {
        Unsplash.request("/photos/random?count=\(count)&w=\(Int(UIScreen.main.bounds.width))&username=\(username)", completion: completion)?.resume()
    }

    static func search(for query: String, page: Int, perPage: Int = 10, completion: @escaping (JSON?) -> Void) {
        Unsplash.request("/search/photos?query=\(query)&page=\(page)&per_page=\(perPage)", completion: completion)?.resume()
    }
}

extension Unsplash {

    enum Authorization {

        case none
        case user(authHeader: String)

        static var current: Authorization = .none

        var header: String {
            switch self {
            case .none: return "Client-ID " + Authorization.clientId
            case .user(let accessToken): return "Bearer " + accessToken
            }
        }

        static let clientId: String = {
            guard let clientId = ProcessInfo.processInfo.environment["UNSPLASH_CLIENT_ID"] else {
                preconditionFailure("Unsplash Client ID not set")
            }
            return clientId
        }()
    }
}
