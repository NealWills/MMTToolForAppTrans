import Foundation

extension String {
    var mmt_normalizedLocalizationKey: String {
        replacingOccurrences(of: "\u{200B}", with: "")
    }
}
