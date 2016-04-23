//
//  ActiveRecord.swift
//  Pods
//
//  Created by 钟建明 on 16/3/25.
//
//

import Foundation

public class ActiveRecord {
    public class var primaryKey: String? {
        return "ID"
    }
    
    public class var ignoreProperties: [String] {
        return []
    }
    
    public class var table: String {
        return String(self)
    }
    
    public var properties: [(String, Any)] {
        return Mirror(reflecting: self).children
            .filter {
                $0.label != nil &&
                !self.dynamicType.ignoreProperties.contains($0.label!)
            }
            .map { ($0.label!, $0.value) }
    }
    
    public init() {
        
    }
    
    public var ID: Int = -1
    
    public var insertSql: String {
        let properties = self.properties
        var columns = [String]()
        var values = [String]()
        for (column, value) in properties {
            columns.append("\"\(column)\"")
            values.append(SQLValueTransformer.transform(value))
        }
        
        let columnsToken = columns.joinWithSeparator(", ")
        let valuesToken = values.joinWithSeparator(", ")
        
        return "INSERT INTO \(self.dynamicType.table) (\(columnsToken)) VALUES (\(valuesToken));"
    }
    
    public var updateSql: String {
        let primaryKeyName = self.dynamicType.primaryKey!
        
        let properties = self.properties
        let set = properties
            .filter { $0.0 != primaryKeyName }
            .map { "\"\($0.0)\" = \(SQLValueTransformer.transform($0.1))" }
            .joinWithSeparator(", ")
        let primaryKeyValue = SQLValueTransformer.transform(properties
            .filter { $0.0 == primaryKeyName }
            .first?.1 ?? ID)
        let table = self.dynamicType.table
        return "UPDATE \(table) SET \(set) WHERE \"\(primaryKeyName)\" = \(primaryKeyValue);"
    }
    
    public var deleteSql: String {
        let primaryKeyName = self.dynamicType.primaryKey!
        let primaryKeyValue = SQLValueTransformer.transform(properties
            .filter { $0.0 == primaryKeyName }
            .first?.1 ?? ID)
        
        return "DELETE FROM \(self.dynamicType.table) WHERE \"\(primaryKeyName)\" = \(primaryKeyValue);"
    }
}























