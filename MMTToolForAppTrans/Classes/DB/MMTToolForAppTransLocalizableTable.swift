
import WCDBSwift

/// Model representing a localizable string entry in the translation database.
/// This model stores translations in multiple languages (English, Simplified Chinese,
/// Traditional Chinese, French, German, Spanish, Italian, Polish) along with metadata.
final
class MMTToolForAppTransLocalizableModel: TableCodable, Copyable {
    
    /// Unique primary key (auto-increment)
    var identifier: Int
    
    /// Description or status of the record ("Add", "Update", "Delete")
    var description: String?
    
    /// Timestamp when the record was created
    var create_date: Date?
    
    /// Timestamp when the record was last updated
    var update_date: Date?
    
    /// Soft delete flag (0 = active, 1 = deleted)
    var is_delete: Int
    
    /// Key or identifier for the localizable string
    var key: String?
    
    /// English (US) translation value
    var value_en_US: String?
    
    /// Simplified Chinese translation value
    var value_zh_hans: String?
    
    /// Traditional Chinese translation value
    var value_zh_hant: String?
    
    /// French translation value
    var value_fr: String?
    
    /// German translation value
    var value_de: String?
    
    /// Spanish translation value
    var value_es: String?
    
    /// Italian translation value
    var value_it: String?
    
    /// Polish translation value
    var value_pl: String?

    /// Coding keys for encoding/decoding with WCDB
    enum CodingKeys: String, CodingTableKey {
        typealias Root = MMTToolForAppTransLocalizableModel
        case identifier = "id"
        case description
        
        case create_date
        case update_date
        case is_delete
        
        case key
        case value_en_US
        case value_zh_hans
        case value_zh_hant
        case value_fr
        case value_de
        case value_es
        case value_it
        case value_pl
        
        /// Define database table schema with column constraints
        /// - identifier: Primary key with auto-increment
        /// - description: Non-null with default value
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(identifier, isPrimary: true, isAutoIncrement: true, isUnique: true)
            BindColumnConstraint(description, isNotNull: true, defaultTo: "defaultDescription")
        }
    }
    
    /// Equatable conformance: compare models by their unique identifier
    static func == (lhs: MMTToolForAppTransLocalizableModel, rhs: MMTToolForAppTransLocalizableModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    /// Initialize a new localization model with optional translation values.
    /// - Parameters:
    ///   - key: The unique key for this localizable string
    ///   - value_en_US: English (US) translation
    ///   - value_zh_hans: Simplified Chinese translation
    ///   - value_zh_hant: Traditional Chinese translation
    ///   - value_fr: French translation
    ///   - value_de: German translation
    ///   - value_es: Spanish translation
    ///   - value_it: Italian translation
    ///   - value_pl: Polish translation
    init(
        key: String? = nil,
        value_en_US: String? = nil,
        value_zh_hans: String? = nil,
        value_zh_hant: String? = nil,
        value_fr: String? = nil,
        value_de: String? = nil,
        value_es: String? = nil,
        value_it: String? = nil,
        value_pl: String? = nil
    ) {
        identifier = 0
        description = "Add"
        create_date = .init()
        update_date = .init()
        is_delete = 0
        self.key = key
        self.value_en_US = value_en_US
        self.value_zh_hans = value_zh_hans
        self.value_zh_hant = value_zh_hant
        self.value_fr = value_fr
        self.value_de = value_de
        self.value_es = value_es
        self.value_it = value_it
        self.value_pl = value_pl
    }
    
    /// Create a deep copy of this localization model.
    /// - Returns: A new instance with the same properties as the current model
    func copyModel() -> MMTToolForAppTransLocalizableModel {
        let model = MMTToolForAppTransLocalizableModel(
            key: key,
            value_en_US: value_en_US,
            value_zh_hans: value_zh_hans,
            value_zh_hant: value_zh_hant,
            value_fr: value_fr,
            value_de: value_de,
            value_es: value_es,
            value_it: value_it,
            value_pl: value_pl
        )
        model.identifier = identifier
        model.is_delete = is_delete
        model.create_date = create_date
        model.update_date = update_date
        model.description = description
        return model
    }
    
}

// MARK: - Database Table Management
// MARK: Initialization

/// Database table manager for localizable string entries.
/// Provides CRUD operations (Create, Read, Update, Delete) for localization records.
class MMTToolForAppTransLocalizableTable {
    
    /// Tracks the highest identifier in the table (used for auto-increment simulation)
    var lastId: Int = 0
    
    /// Get the shared database instance managed by MMTToolForAppTransDBManager
    /// - Returns: The WCDB Database instance
    static func db() -> Database {
        return MMTToolForAppTransDBManager.shared.db
    }

    static func table() -> MMTToolForAppTransLocalizableTable? {
        return MMTToolForAppTransDBManager.shared.localizableTable
    }
    
    /// Database table name constant
    static let table_name = "mmt_table_localizable"
    
    /// Create the localizable table if it doesn't exist, and initialize lastId.
    /// This method should be called once during application initialization.
    func createTable() {
        try? MMTToolForAppTransLocalizableTable.db().create(table: MMTToolForAppTransLocalizableTable.table_name, of: MMTToolForAppTransLocalizableModel.self)
        // Retrieve the highest identifier from existing records to continue auto-increment
        let lastItem: MMTToolForAppTransLocalizableModel? = try? MMTToolForAppTransLocalizableTable.db().getObject(
            on: MMTToolForAppTransLocalizableModel.Properties.all,
            fromTable: MMTToolForAppTransLocalizableTable.table_name,
            orderBy: [MMTToolForAppTransLocalizableModel.Properties.identifier.asOrder().order(.descending)]
        )
        lastId = lastItem?.identifier ?? 0
    }
}

// MARK: - Create Operations
// MARK: Insert

extension MMTToolForAppTransLocalizableTable {
    /// Insert a new localization record into the database.
    /// - Parameter item: The MMTToolForAppTransLocalizableModel instance to insert (optional)
    /// - Returns: `.success(0)` on success, or `.failure(NSError)` if item is nil or a database error occurs
    func insertNew(_ item: MMTToolForAppTransLocalizableModel?) -> Result<Int, NSError> {
        guard let item = item else {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Item is nil"]))
        }
        do {
            // Auto-increment the identifier
            lastId += 1
            item.identifier = lastId
            item.description = "Insert"
            try MMTToolForAppTransLocalizableTable.db().insert(item, intoTable: MMTToolForAppTransLocalizableTable.table_name)
        } catch {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to insert localization record, error: \(error)"]))
        }
        return .success(0)
    }
}

// MARK: - Delete Operations
// MARK: Soft Delete

extension MMTToolForAppTransLocalizableTable {
    /// Soft-delete a localization record by setting the is_delete flag to 1.
    /// This does not physically remove the record from the database.
    /// - Parameter item: The MMTToolForAppTransLocalizableModel instance to delete (optional)
    /// - Returns: Result<0, NSError> on success, Result with error on failure (item is nil or database error)
    func deleteItem(_ item: MMTToolForAppTransLocalizableModel?) -> Result<Int, NSError> {
        guard let item = item else {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Item is nil"]))
        }
        // Mark the item as deleted without physically removing it
        item.is_delete = 1
        item.update_date = .init()
        item.description = "Delete"
        do {
            try MMTToolForAppTransLocalizableTable.db().update(
                table: MMTToolForAppTransLocalizableTable.table_name,
                on: MMTToolForAppTransLocalizableModel.Properties.all,
                with: item,
                where: MMTToolForAppTransLocalizableModel.Properties.identifier == item.identifier
            )
            return .success(0)
        } catch {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete localization record, error: \(error)"]))
        }
    }
}

// MARK: - Update Operations
// MARK: Modify Existing Records

extension MMTToolForAppTransLocalizableTable {
    /// Update an existing localization record in the database.
    /// The model's identifier is used to match the record to update.
    /// - Parameter item: The MMTToolForAppTransLocalizableModel instance with updated data (optional)
    /// - Returns: Result<0, NSError> on success, Result with error on failure (item is nil or database error)
    func update(_ item: MMTToolForAppTransLocalizableModel?) -> Result<Int, NSError> {
        guard let item = item else {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Item is nil"]))
        }
        // Update the modification timestamp
        item.update_date = .init()
        item.description = "Update"
        do {
            try MMTToolForAppTransLocalizableTable.db().update(
                table: MMTToolForAppTransLocalizableTable.table_name,
                on: MMTToolForAppTransLocalizableModel.Properties.all,
                with: item,
                where: MMTToolForAppTransLocalizableModel.Properties.identifier == item.identifier
            )
            return .success(0)
        } catch {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update localization record, error: \(error)"]))
        }
    }
}

// MARK: - Query Operations
// MARK: Read Records

extension MMTToolForAppTransLocalizableTable {
    /// Retrieve all localization records from the database.
    /// - Returns: Result containing an array of MMTToolForAppTransLocalizableModel instances on success, or an NSError on failure
    func getAllItems() -> Result<[MMTToolForAppTransLocalizableModel], NSError> {
        do {
            let allObject: [MMTToolForAppTransLocalizableModel] = try MMTToolForAppTransLocalizableTable.db().getObjects(
                on: MMTToolForAppTransLocalizableModel.Properties.all,
                fromTable: MMTToolForAppTransLocalizableTable.table_name
            )
            return .success(allObject)
        } catch {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch all localization records, error: \(error)"]))
        }
    }
    
    /// Class method to retrieve a localization item by key (convenience method).
    /// - Parameter key: The key value to search for (optional)
    /// - Returns: `.success(model)` or `.success(nil)` when query succeeds, `.failure(NSError)` when key is nil or query fails
    class func getItem(key: String?) -> Result<MMTToolForAppTransLocalizableModel?, NSError> {
        // MEDBManager.shared.wifiTable?.getItem(ssid: ssid)
        return MMTToolForAppTransLocalizableTable().getItem(key: key)
    }
    
    /// Retrieve a localization record by its key field.
    /// Returns the most recently created record if multiple records share the same key.
    /// - Parameter key: The key value to search for (optional)
    /// - Returns: `.success(model)` or `.success(nil)` when query succeeds, `.failure(NSError)` when key is nil or query fails
    func getItem(key: String?) -> Result<MMTToolForAppTransLocalizableModel?, NSError> {
        guard let key else { return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Key is nil"])) }
        do {
            let item: MMTToolForAppTransLocalizableModel? = try MMTToolForAppTransLocalizableTable.db().getObject(
                on: MMTToolForAppTransLocalizableModel.Properties.all,
                fromTable: MMTToolForAppTransLocalizableTable.table_name,
                where: MMTToolForAppTransLocalizableModel.Properties.key == key,
                orderBy: [MMTToolForAppTransLocalizableModel.Properties.identifier.asOrder().order(.descending)]
            )
            return .success(item)
        } catch {
            return .failure(NSError(domain: "MMTToolForAppTransLocalizableTable", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch localization record by key, error: \(error)"]))
        }
    }
}
