//
//  TableColumn.swift
//  Pods
//
//  Created by 钟建明 on 16/4/26.
//
//

import Foundation

enum TableColumnType: Statement {
    case Integer, Real, Text, Blob
    
    var sqlString: String {
        switch self {
        case .Integer:
            return "INTEGER"
        case .Real:
            return "REAL"
        case .Text:
            return "TEXT"
        case .Blob:
            return "BLOB"
        }
    }
}

public class TableColumn<T>: Statement {
    let name: String
    let type: TableColumnType
    
    var isPrimaryKey = false
    var defaultValue: T? = nil
    var isNotNull = false
    var isUnique = false
    var isAutoIncrement = false
    
    init(name: String, type: TableColumnType) {
        self.name = name
        self.type = type
    }
    
    public static func integer(name: String) -> TableColumn<Int> {
        return TableColumn<Int>(name: name, type: .Integer)
    }
    
    public static func text(name: String) -> TableColumn<String> {
        return TableColumn<String>(name: name, type: .Text)
    }
    
    public static func real(name: String) -> TableColumn<Double> {
        return TableColumn<Double>(name: name, type: .Real)
    }
    
    public static func blob(name: String) -> TableColumn<NSData> {
        return TableColumn<NSData>(name: name, type: .Blob)
    }
    
    public func primaryKey() -> TableColumn<T> {
        self.isPrimaryKey = true
        return self
    }
    
    public func defaultValue(value: T) -> TableColumn<T> {
        self.defaultValue = value
        return self
    }
    
    public func notNull() -> TableColumn<T> {
        self.isNotNull = true
        return self
    }
    
    public func unique() -> TableColumn<T> {
        self.isUnique = true
        return self
    }
    
    public func autoIncrement() -> TableColumn<T> {
        self.isAutoIncrement = true
        return self
    }
    
    public var sqlString: String {
        let primaryKeyToken = isPrimaryKey ? " PRIMARY KEY" : ""
        let notNullToken = isNotNull ? " NOT NULL" : ""
        var defaultValueToken: String
        if let defaultValue = self.defaultValue {
            defaultValueToken = " DEFAULT \(SQLValueTransformer.transform(defaultValue))"
        } else {
            defaultValueToken = ""
        }
        let uniqueToken = isUnique ? " UNIQUE" : ""
        let autoIncrementToken = isAutoIncrement ? " AUTOINCREMENT" : ""
        return "\(name) \(type.sqlString)\(primaryKeyToken)\(notNullToken)\(defaultValueToken)\(uniqueToken)\(autoIncrementToken)"
    }
}






























