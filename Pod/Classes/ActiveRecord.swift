//
//  ActiveRecord.swift
//  Pods
//
//  Created by 钟建明 on 16/3/25.
//
//

import Foundation

public protocol ResultSet {
    func integer(column: String) -> Int?
    func string(column: String) -> String?
    func double(column: String) -> Double?
    func bool(column: String) -> Bool?
    func date(column: String) -> NSDate?
    func data(column: String) -> NSData?
}

public class ActiveRecord {
    public class var primaryKey: String {
        return "ID"
    }
    
    public class var ignoreProperties: [String] {
        return []
    }
    
    public class var table: String {
        return String(self)
    }
    
    public class func map<T: ActiveRecord>(resultSet: ResultSet) -> T? {
        return nil
    }
    
    public var properties: [(String, Any)] {
        return Mirror(reflecting: self).children
            .filter {
                $0.label != nil &&
                !self.dynamicType.ignoreProperties.contains($0.label!)
            }
            .map { ($0.label!, $0.value) }
    }
    
    public required init() {
        
    }
    
    public var ID: Int = -1
    
    public var primaryKeyValue: Any {
        let primaryKey = self.dynamicType.primaryKey
        if primaryKey == "ID" {
            return self.ID
        } else {
            return self.properties.filter { $0.0 == primaryKey }.first!.1
        }
    }
}

public class ActiveRecordStatement: Statement {
    let activeRecord: ActiveRecord
    
    public init(activeRecord: ActiveRecord) {
        self.activeRecord = activeRecord
    }
    
    public var sqlString: String {
        fatalError()
    }
}

public class ActiveRecordInsertStatement: ActiveRecordStatement {
    public override var sqlString: String {
        let properties = activeRecord.properties
        var columns = [String]()
        var values = [String]()
        for (column, value) in properties {
            columns.append("\"\(column)\"")
            values.append(SQLValueTransformer.transform(value))
        }
        
        let columnsToken = columns.joinWithSeparator(", ")
        let valuesToken = values.joinWithSeparator(", ")
        
        return "INSERT INTO \(activeRecord.dynamicType.table) (\(columnsToken)) VALUES (\(valuesToken));"
    }
}

public class ActiveRecordUpdateStatement: ActiveRecordStatement {
    public override var sqlString: String {
        let primaryKeyName = activeRecord.dynamicType.primaryKey
        
        let properties = activeRecord.properties
        let set = properties
            .filter { $0.0 != primaryKeyName }
            .map { "\"\($0.0)\" = \(SQLValueTransformer.transform($0.1))" }
            .joinWithSeparator(", ")
        let primaryKeyValue = SQLValueTransformer.transform(activeRecord.primaryKeyValue)
        let table = activeRecord.dynamicType.table
        return "UPDATE \(table) SET \(set) WHERE \"\(primaryKeyName)\" = \(primaryKeyValue);"
    }
}

public class ActiveRecordDeleteStatement: ActiveRecordStatement {
    public override var sqlString: String {
        let primaryKeyName = activeRecord.dynamicType.primaryKey
        let primaryKeyValue = SQLValueTransformer.transform(activeRecord.primaryKeyValue)
        
        return "DELETE FROM \(activeRecord.dynamicType.table) WHERE \"\(primaryKeyName)\" = \(primaryKeyValue);"
    }
}























