
import Foundation

extension Date {

    func format(relativeTo otherDate: Date) -> String {

        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .weekOfYear], from: otherDate, to: self)

        let suffix: String
        switch self.compare(otherDate) {
        case .orderedSame: suffix = ""
        case .orderedAscending: suffix = "ago"
        case .orderedDescending: suffix = "from now"
        }

        var output: [String] = []

        for component in [Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second] {

            guard let value = components.value(for: component).map(abs) else { continue }
            guard value != 0 else { continue }

            switch component {
            case .second: output.append("\(value) s")
            case .minute: output.append("\(value) m")
            case .hour: output.append("\(value) h")
            case .day:
                if value < 7 {
                    output.append("\(value) days")
                } else {
                    output.append("\(value / 7) weeks")
                    output.append("\(value % 7) days")
                    output.append(suffix)
                    return output.joined(separator: " ")
                }

            default: break
            }

            if output.count <= 2 {
                output.append(suffix)
                return output.joined(separator: " ")
            }
        }

        if output.count == 0 { return "now" }
        output.append(suffix)
        return output.joined(separator: " ")
    }
}
