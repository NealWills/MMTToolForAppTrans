
import WCDBSwift

class MMTToolForAppTransDBManager {
    static let shared = MMTToolForAppTransDBManager()
    private(set) var db: Database!

    var localizableTable: MMTToolForAppTransLocalizableTable?

}

extension MMTToolForAppTransDBManager {
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
        
        var isDirectory: ObjCBool = true
        let isFileExist = FileManager.default.fileExists(atPath: fileDir, isDirectory: &isDirectory)
        if isFileExist {
            if isDirectory.boolValue {
                //
            } else {
                try? FileManager.default.removeItem(atPath: fileDir)
                try? FileManager.default.createDirectory(at: URL(fileURLWithPath: fileDir), withIntermediateDirectories: true)
            }
        } else {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: fileDir), withIntermediateDirectories: true)
        }
        
        db = Database(at: filePath)
        
        localizableTable = MMTToolForAppTransLocalizableTable()
        localizableTable?.createTable()
        
    }
    
    // add
    @discardableResult class func insertNewItem(with item: MMTToolForAppTransDBOperateUnit) -> Result<Int, NSError>? {
        switch item {
        case .localizableTable(let model):
            MMTToolForAppTransDBManager.shared.localizableTable?.insertNew(model)
        }
    }
    
    // delete
    @discardableResult class func deleteNewItem(with item: MMTToolForAppTransDBOperateUnit) -> Result<Int, NSError>? {
        switch item {
        case .localizableTable(let model):
            MMTToolForAppTransDBManager.shared.localizableTable?.deleteItem(model)
        }
    }
    
    // update
    @discardableResult class func updateNewItem(with item: MMTToolForAppTransDBOperateUnit) -> Result<Int, NSError>? {
        switch item {
        case .localizableTable(let model):
            MMTToolForAppTransDBManager.shared.localizableTable?.update(model)
        }
    }
}

fileprivate
extension String {
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
