
import WCDBSwift
import MMTToolForXCGLog

/// Database manager for all WCDB operations.
/// Manages database initialization, table creation, and CRUD operations.
/// Provides centralized access to localization table through singleton pattern.
class MMTToolForAppTransDBManager {
    /// Shared singleton instance for database operations.
    static let shared = MMTToolForAppTransDBManager()
    
    /// The WCDB Database instance for executing operations.
    private(set) var db: Database!

    /// Table instance for managing localization records.
    var localizableTable: MMTToolForAppTransLocalizableTable?

}

extension MMTToolForAppTransDBManager {
    /// Initializes the database and creates required tables.
    /// Sets up the database file path in Documents directory.
    /// Creates localization table schema if not exists.
    func initTable() {
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        var strPath = documentsDirectory.absoluteString
        if strPath[0 ..< 7] == "file://" {
            strPath = strPath.replacingOccurrences(of: "file://", with: "")
        }

        let rootDir = strPath
        
        let fileDir = rootDir + ".MMTToolForAppTrans/db/"
        let filePath = fileDir + "db.sqlite3"
        
        XCGLogger.log("[DBManager] Initializing database at path: \(filePath)", level: .debug)
        
        var isDirectory: ObjCBool = true
        let isFileExist = FileManager.default.fileExists(atPath: fileDir, isDirectory: &isDirectory)
        if isFileExist {
            if isDirectory.boolValue {
                XCGLogger.log("[DBManager] Database directory already exists", level: .debug)
            } else {
                XCGLogger.log("[DBManager] Removing existing file at database directory path", level: .warning)
                try? FileManager.default.removeItem(atPath: fileDir)
                try? FileManager.default.createDirectory(at: URL(fileURLWithPath: fileDir), withIntermediateDirectories: true)
            }
        } else {
            XCGLogger.log("[DBManager] Creating new database directory", level: .debug)
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: fileDir), withIntermediateDirectories: true)
        }
        
        db = Database(at: filePath)
        XCGLogger.log("[DBManager] Database instance created successfully", level: .info)
        
        localizableTable = MMTToolForAppTransLocalizableTable()
        localizableTable?.createTable()
        XCGLogger.log("[DBManager] Localization table initialized", level: .info)
        
    }
    
    /// Inserts a new record into the database.
    /// - Parameter item: The database operation unit containing the model to insert.
    /// - Returns: Result containing the auto-incremented ID on success, or NSError on failure.
    @discardableResult class func insertNewItem(with item: MMTToolForAppTransDBOperateUnit) -> Result<Int, NSError>? {
        switch item {
        case .localizableTable(let model):
            XCGLogger.log("[DBManager] Attempting to insert new localization record with key: \(model.key ?? "nil")", level: .debug)
            let result = MMTToolForAppTransDBManager.shared.localizableTable?.insertNew(model)
            if case .success(let id) = result ?? nil {
                XCGLogger.log("[DBManager] Insert successful with ID: \(id)", level: .info)
            } else {
                XCGLogger.log("[DBManager] Insert failed", level: .error)
            }
            return result
        }
    }
    
    /// Deletes a record from the database (soft-delete via is_delete flag).
    /// - Parameter item: The database operation unit containing the model to delete.
    /// - Returns: Result containing the number of affected rows on success, or NSError on failure.
    @discardableResult class func deleteNewItem(with item: MMTToolForAppTransDBOperateUnit) -> Result<Int, NSError>? {
        switch item {
        case .localizableTable(let model):
            XCGLogger.log("[DBManager] Attempting to delete localization record with ID: \(model.id ?? -1)", level: .debug)
            let result = MMTToolForAppTransDBManager.shared.localizableTable?.deleteItem(model)
            if case .success(let rows) = result ?? nil {
                XCGLogger.log("[DBManager] Delete successful, affected rows: \(rows)", level: .info)
            } else {
                XCGLogger.log("[DBManager] Delete failed", level: .error)
            }
            return result
        }
    }
    
    /// Updates an existing record in the database.
    /// - Parameter item: The database operation unit containing the model to update.
    /// - Returns: Result containing the number of affected rows on success, or NSError on failure.
    @discardableResult class func updateNewItem(with item: MMTToolForAppTransDBOperateUnit) -> Result<Int, NSError>? {
        switch item {
        case .localizableTable(let model):
            XCGLogger.log("[DBManager] Attempting to update localization record with ID: \(model.id ?? -1)", level: .debug)
            let result = MMTToolForAppTransDBManager.shared.localizableTable?.update(model)
            if case .success(let rows) = result ?? nil {
                XCGLogger.log("[DBManager] Update successful, affected rows: \(rows)", level: .info)
            } else {
                XCGLogger.log("[DBManager] Update failed", level: .error)
            }
            return result
        }
    }
}

/// String extension for substring operations using integer-based ranges.
/// Provides safe range-based string slicing compatible with UTF-16 offsets.
fileprivate extension String {
    /// Subscript for string slicing using Range<Int>.
    /// Safely handles out-of-bounds ranges and normalizes invalid ranges.
    subscript(_ range: Range<Int>) -> String {
        if range.lowerBound < 0 {
            return ""
        }
        if count <= range.lowerBound {
            return ""
        }
        if count <= range.upperBound {
            return subString(start: range.lowerBound, end: count)
        }
        return subString(start: range.lowerBound, end: range.upperBound)
    }
    
    /// Extracts a substring using start and end integer indices.
    /// Safely clamps indices to valid string bounds and handles edge cases.
    /// - Parameters:
    ///   - start: The starting index (0-based).
    ///   - end: The ending index (exclusive, 0-based).
    /// - Returns: Extracted substring, or empty string if indices are invalid.
    func subString(start: Int, end: Int) -> String {
        var start = start
        start = start < 0 ? 0 : start
        start = start >= count ? count : start
        var end = end
        end = end < 0 ? 0 : end
        end = end >= count ? count : end
        if start > end {
            let l = end
            start = end
            end = l
        }
        #if swift(>=5.0)
        let startIndex = String.Index(utf16Offset: start, in: self)
        let endIndex = String.Index(utf16Offset: end, in: self)
        #else
        let startIndex = String.Index(encodedOffset: start)
        let endIndex = String.Index(encodedOffset: end)
        #endif
        return String(self[startIndex ..< endIndex])
    }
}
