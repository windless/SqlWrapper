//
//  CreateTableStatement.swift
//  Pods
//
//  Created by 钟建明 on 16/4/26.
//
//

import Foundation

public class CreateTableStatement: Statement {
    let name: String
    
    private var columns: [Statement]
    
    public init(tableName: String, initializer: (CreateTableStatement -> Void)? = nil) {
        self.name = tableName
        self.columns = []
        
        initializer?(self)
    }
    
    public func id() {
        self.integer("ID").primaryKey().autoIncrement()
    }
    
    public func integer(column: String) -> TableColumn<Int> {
        let column = TableColumn<Int>(name: column, type: .Integer)
        self.columns.append(column)
        return column
    }
    
    public func text(column: String) -> TableColumn<String> {
        let column = TableColumn<String>(name: column, type: .Text)
        self.columns.append(column)
        return column
    }
    
    public func real(column: String) -> TableColumn<Double> {
        let column = TableColumn<Double>(name: column, type: .Real)
        self.columns.append(column)
        return column
    }
    
    public func blob(column: String) -> TableColumn<NSData> {
        let column = TableColumn<NSData>(name: column, type: .Blob)
        self.columns.append(column)
        return column
    }
    
    public var sqlString: String {
        let columnsToken = columns.map { $0.sqlString }.joinWithSeparator(", ")
        return "CREATE TABLE \(name)(\(columnsToken));"
    }
}

public class AddTableColumnsStatement: CreateTableStatement {
    override public var sqlString: String {
        return columns.map { "ALTER TABLE \(name) ADD COLUMN \($0.sqlString);" }
            .joinWithSeparator("\n")
    }
}

public class RenameTableStatement: Statement {
    private let tableName: String
    private let newTableName: String
    
    public init(tableName: String, newTableName: String) {
        self.tableName = tableName
        self.newTableName = newTableName
    }
    
    public var sqlString: String {
        return "ALTER TABLE \(tableName) RENAME TO \(newTableName);"
    }
}

public class DropTableStatement: Statement {
    private let table: String
    
    public init(table: String) {
        self.table = table
    }
    
    public var sqlString: String {
        return "DROP TABLE \(table);"
    }
}

public class AddIndexStatement: Statement {
    private let table: String
    private let columns: [String]
    
    public init(table: String, columns: [String]) {
        self.table = table
        self.columns = columns
    }
    
    public var sqlString: String {
        let columnsToken = columns.joinWithSeparator(", ")
        let indexName = columns.joinWithSeparator("_") + "_index"
        return "CREATE INDEX \(indexName) ON \(table) (\(columnsToken));"
    }
}































