
import Foundation
import JSON

extension JSON {

    var url: URL? {
        switch self {
        case .string(let string): return URL(string: string)
        default: return nil
        }
    }

    var date: Date? {
        switch self {
        case .string(let string): return JSON.dateFormatter.date(from: string)
        default: return nil
        }
    }

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()
}

extension URL: JSONInitializable {
    public init(json: JSON) throws {

        switch json {
        case .string(let string):
            guard let url = URL(string: string) else {
                throw JSON.Error.badValue(json)
            }
            self = url
        default: throw JSON.Error.badValue(json)
        }
    }
}

extension Date: JSONInitializable {

    public init(json: JSON) throws {
        switch json {
        case .string(let string):
            guard let date = JSON.dateFormatter.date(from: string) else {
                throw JSON.Error.badValue(json)
            }
            self = date
        default: throw JSON.Error.badValue(json)
        }
    }
}
