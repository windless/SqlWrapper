//
//  SQLMigration.swift
//  Pods
//
//  Created by 钟建明 on 16/3/25.
//
//

import Foundation

public class SQLMigration {
    let version: Int
    var sqlStatements = [String]()

    public init(version: Int) {
        self.version = version
    }

    public func createTable(tableName: String, block: SQLMigrationTable -> Void) {
        let table = SQLMigrationTable(tableName: tableName)
        block(table)
        sqlStatements.append(table.toSql())
    }

    public func addIndex(tableName: String, column: String) {
        let sql = "CREATE INDEX \(column) ON \(tableName) (\(column));"
        sqlStatements.append(sql)
    }

    public func addIndex(tableName: String, indexName: String, columns: String...) {
        let columnsToken = columns.joinWithSeparator(", ")
        let sql = "CREATE INDEX \(indexName) ON \(tableName) (\(columnsToken));"
        sqlStatements.append(sql)
    }

    public func dropTable(tableName: String) {
        let sql = "DROP TABLE \(tableName);"
        sqlStatements.append(sql)
    }

    public func addColumnTo(tableName: String, block: SQLMigrationTable -> Void) {
        let table = SQLMigrationTable(tableName: tableName, isAddColumn: true)
        block(table)
        sqlStatements.append(table.toSql())
    }

    public func raw(sql: String) {
        if !sql.hasSuffix(";") {
            sqlStatements.append(sql + ";")
        } else {
            sqlStatements.append(sql)
        }
    }

    public func buildScheme() -> String {
        return sqlStatements.joinWithSeparator("\n")
    }
}
