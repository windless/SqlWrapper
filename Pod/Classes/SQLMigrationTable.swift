//
//  SQLMigrationTable.swift
//  Pods
//
//  Created by 钟建明 on 16/3/25.
//
//

import Foundation

public class SQLMigrationTable: SQLSqlable {
    let name: String
    
    private var columns: [SQLSqlable]
    private let isAddColumn: Bool
    
    public init(tableName: String, isAddColumn: Bool = false) {
        self.name = tableName
        self.columns = []
        self.isAddColumn = isAddColumn
    }
    
    public func id() {
        self.integer("ID").primaryKey().notNull()
    }
    
    public func integer(column: String) -> SQLMigrationTableColumn<Int> {
        let column = SQLMigrationTableColumn<Int>(name: column, type: .Integer)
        self.columns.append(column)
        return column
    }
    
    public func text(column: String) -> SQLMigrationTableColumn<String> {
        let column = SQLMigrationTableColumn<String>(name: column, type: .Text)
        self.columns.append(column)
        return column
    }
    
    public func real(column: String) -> SQLMigrationTableColumn<Double> {
        let column = SQLMigrationTableColumn<Double>(name: column, type: .Real)
        self.columns.append(column)
        return column
    }
    
    public func blob(column: String) -> SQLMigrationTableColumn<NSData> {
        let column = SQLMigrationTableColumn<NSData>(name: column, type: .Blob)
        self.columns.append(column)
        return column
    }
    
    public func toSql() -> String {
        let columnsToken = columns.map { $0.toSql() }.joinWithSeparator(", ")
        if isAddColumn {
            return columns.map { "ALTER TABLE \(name) ADD COLUMN \($0.toSql());" }
                .joinWithSeparator("\n")
        } else {
            if columns.count > 1 {
                return "CREATE TABLE \(name)(\(columnsToken));"
            } else {
                return "CREATE TABLE \(name)(\(columnsToken));"
            }
        }
    }
}

public class SQLMigrationTableColumn<T>: SQLSqlable {
    let name: String
    let type: SQLMigrationTableColumnType
    
    var isPrimaryKey = false
    var defaultValue: T? = nil
    var isNotNull = false
    var isUnique = false
    
    init(name: String, type: SQLMigrationTableColumnType) {
        self.name = name
        self.type = type
    }
    
    public func primaryKey() -> SQLMigrationTableColumn<T> {
        self.isPrimaryKey = true
        return self
    }
    
    public func defaultValue(value: T) -> SQLMigrationTableColumn<T> {
        self.defaultValue = value
        return self
    }
    
    public func notNull() -> SQLMigrationTableColumn<T> {
        self.isNotNull = true
        return self
    }
    
    public func unique() -> SQLMigrationTableColumn<T> {
        self.isUnique = true
        return self
    }
    
    public func toSql() -> String {
        let primaryKeyToken = isPrimaryKey ? " PRIMARY KEY" : ""
        let notNullToken = isNotNull ? " NOT NULL" : ""
        var defaultValueToken: String
        if let defaultValue = self.defaultValue {
            defaultValueToken = " DEFAULT \(SQLValueTransformer.transform(defaultValue))"
        } else {
            defaultValueToken = ""
        }
        let uniqueToken = isUnique ? " UNIQUE" : ""
        return "\(name) \(type.toSql())\(primaryKeyToken)\(notNullToken)\(defaultValueToken)\(uniqueToken)"
    }
}

public enum SQLMigrationTableColumnType: SQLSqlable {
    case Integer, Real, Text, Blob
    
    public func toSql() -> String {
        switch self {
        case .Integer:
            return "INT"
        case .Real:
            return "REAL"
        case .Text:
            return "TEXT"
        case .Blob:
            return "BLOB"
        }
    }
}















