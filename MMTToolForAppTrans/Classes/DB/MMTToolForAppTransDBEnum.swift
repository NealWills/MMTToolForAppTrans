import Foundation
import WCDBSwift

/// A protocol for models that can create a copy of themselves.
protocol MMTToolForAppTransLocalCopyable {
    /// The copied model type.
    associatedtype T

    /// Creates and returns a copied model instance.
    /// - Returns: A copied model.
    func copyModel() -> T
}

/// A protocol for models that can be converted into key-value parameters.
protocol MMTToolForAppTransGenerateParamsProtocol {
    /// Converts the model into a dictionary representation.
    /// - Returns: A dictionary used for database or network parameters.
    func transToParams() -> [String: Any]
}

/// Default implementation for converting a `TableCodable` model to parameters.
extension MMTToolForAppTransGenerateParamsProtocol where Self: TableCodable {
    /// Converts all reflected properties into a parameter dictionary.
    /// `Date` values are converted to UNIX timestamps.
    /// - Returns: A parameter dictionary of the current model.
    func transToParams() -> [String: Any] {
        var params: [String: Any] = .init()
        let mirror = Mirror(reflecting: self)
        _ = mirror.children.compactMap { property in
            if let key = property.label {
                if let obj = property.value as? Date {
                    params[key] = obj.timeIntervalSince1970
                } else {
                    params[key] = property.value
                }
            }
        }
        return params
    }
}

/// Database operation unit definitions.
enum MMTToolForAppTransDBOperateUnit {
    /// Operation unit for the localizable string records table.
    case localizableTable(MMTToolForAppTransLocalizableModel)
}

/// Enables localizable model conversion to parameter dictionary.
extension MMTToolForAppTransLocalizableModel: MMTToolForAppTransGenerateParamsProtocol {}
