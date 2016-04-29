//
//  Migration.swift
//  Pods
//
//  Created by 钟建明 on 16/4/26.
//
//

import Foundation
import FMDB

public extension FMDatabase {
    public func executeStatements(statements: Statement) -> Bool {
        return executeStatements(statements.sqlString)
    }
    
    public func executeQuery(query: Query) -> FMResultSet? {
        do {
            return try executeQuery(query.sqlString, values: [])
        } catch {
            return nil
        }
    }
}

public extension FMDatabase {
    public func createTable(table: String, block: CreateTableStatement -> Void) -> Bool {
        let statement = CreateTableStatement(tableName: table)
        block(statement)
        return executeStatements(statement)
    }
    
    public func addIndex(table: String, columns: String...) -> Bool {
        let statement = AddIndexStatement(table: table, columns: columns)
        return executeStatements(statement)
    }
    
    public func dropTable(table: String) -> Bool {
        let statement = DropTableStatement(table: table)
        return executeStatements(statement)
    }
    
    public func addColumnTo(table: String, block: AddTableColumnsStatement -> Void) -> Bool {
        let statement = AddTableColumnsStatement(tableName: table)
        block(statement)
        return executeStatements(statement)
    }
    
    public func update(query: QueryUpdate) -> Bool {
        return executeStatements(query.sqlString)
    }
    
    public func update(table: String, set: [String: Any?], block: Query.ConditionBlock) -> Bool {
        let query = QueryUpdate(table: table, set: set)
        query.whereWith(block)
        return update(query)
    }
    
    public func delete(query: QueryDelete) -> Bool {
        return executeStatements(query)
    }
    
    public func delete(table: String, block: Query.ConditionBlock) -> Bool {
        let query = QueryDelete(table: table)
        query.whereWith(block)
        return executeStatements(query)
    }
}

public extension FMDatabase {
    public func selectCount(query: QueryCount) -> Int {
        if let resultSet = executeQuery(query) {
            return Int(resultSet.intForColumnIndex(0))
        }
        return 0
    }
    
    public func selectCount(table: String, block: Query.ConditionBlock) -> Int {
        let query = QueryCount(table: table)
        query.whereWith(block)
        return selectCount(query)
    }
    
    public func select(table: String, columns: [String]? = nil, block: Query.ConditionBlock) -> FMResultSet? {
        let query = QuerySelect(table: table, columns: columns)
        query.whereWith(block)
        return executeQuery(query)
    }
}

public extension FMDatabase {
    public func select<T: ActiveRecord>(type: T.Type, block: Query.ConditionBlock) -> [T] {
        let query = QuerySelect(type: type)
        query.whereWith(block)
        
        if let resultSet = executeQuery(query) {
            return map(resultSet, type: type)
        }
        return []
    }
    
    public func selectCount<T: ActiveRecord>(type: T.Type, block: Query.ConditionBlock) -> Int {
        let query = QueryCount(type: type)
        query.whereWith(block)
        return selectCount(query)
    }
    
    public func selectSingle<T: ActiveRecord>(type: T.Type, block: Query.ConditionBlock) -> T? {
        let query = QuerySelect(type: type)
        query.whereWith(block)
        
        if let resultSet = executeQuery(query) {
            return map(resultSet, type: type).first
        }
        return nil
    }
    
    private func map<T: ActiveRecord>(resultSet: FMResultSet, type: T.Type) -> [T] {
        var result = [T]()
        while resultSet.next() {
            let activeRecord: T? = type.map(SWResultSet(resultSets: resultSet, type: type))
            if let a = activeRecord {
                result.append(a)
            }
        }
        return result
    }
}

public extension FMDatabase {
    public func insertRecord(activeRecord: ActiveRecord) -> Int? {
        do {
            let statement = ActiveRecordInsertStatement(activeRecord: activeRecord)
            try self.executeUpdate(statement.sqlString, values: [])
            let lastInsertRowId = Int(self.lastInsertRowId())
            if activeRecord.dynamicType.primaryKey == "ID" {
                activeRecord.ID = lastInsertRowId
            }
            return lastInsertRowId
        } catch {
            return nil
        }
    }
    
    public func insertRecords(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if insertRecord(activeRecord) != nil {
                return false
            }
        }
        return true
    }
    
    public func updateRecord(activeRecord: ActiveRecord) -> Bool {
        do {
            let statement = ActiveRecordUpdateStatement(activeRecord: activeRecord)
            try self.executeUpdate(statement.sqlString, values: [])
            return true
        } catch {
            return false
        }
    }
    
    public func updateRecords(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !updateRecord(activeRecord) {
                return false
            }
        }
        return true
    }
    
    public func insertOrUpdateRecord(activeRecord: ActiveRecord) -> Bool {
        let count = selectCount(activeRecord.dynamicType) { c in
            c(activeRecord.dynamicType.primaryKey) == activeRecord.primaryKeyValue
        }
        if count > 0 {
            updateRecord(activeRecord)
        } else {
            insertRecord(activeRecord)
        }
        return true
    }
    
    public func insertOrUpdateRecords(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !insertOrUpdateRecord(activeRecord) {
                return false
            }
        }
        return true
    }
    
    public func deleteRecord(activeRecord: ActiveRecord) -> Bool {
        do {
            let statement = ActiveRecordDeleteStatement(activeRecord: activeRecord)
            try self.executeUpdate(statement.sqlString, values: [])
            return true
        } catch {
            return false
        }
    }
    
    public func deleteRecords(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !deleteRecord(activeRecord) {
                return false
            }
        }
        return true
    }
}


public class SWResultSet: ResultSet {
    let fmResultSets: FMResultSet
    let type: ActiveRecord.Type
    
    public init(resultSets: FMResultSet, type: ActiveRecord.Type) {
        self.fmResultSets = resultSets
        self.fmResultSets.columnIndexForName("")
        self.type = type
    }
    
    public func integer(column: String) -> Int? {
        let index = indexForColumn(column)
        if index != -1 {
            return Int(fmResultSets.intForColumnIndex(index))
        }
        return nil
    }
    
    public func bool(column: String) -> Bool? {
        let index = indexForColumn(column)
        if index != -1 {
            return fmResultSets.boolForColumnIndex(index)
        }
        return nil
    }
    
    public func string(column: String) -> String? {
        let index = indexForColumn(column)
        if index != -1 {
            return fmResultSets.stringForColumnIndex(index)
        }
        return nil
    }
    
    public func double(column: String) -> Double? {
        let index = indexForColumn(column)
        if index != -1 {
            return fmResultSets.doubleForColumnIndex(index)
        }
        return nil
    }
    
    public func date(column: String) -> NSDate? {
        let index = indexForColumn(column)
        if index != -1 {
            return fmResultSets.dateForColumnIndex(index)
        }
        return nil
    }
    
    public func data(column: String) -> NSData? {
        let index = indexForColumn(column)
        if index != -1 {
            return fmResultSets.dataForColumnIndex(index)
        }
        return nil
    }
    
    private func indexForColumn(column: String) -> Int32 {
        let index = fmResultSets.columnIndexForName(column)
        if index == -1 {
            return fmResultSets.columnIndexForName("\(type.table).\(column)")
        }
        return index
    }
}


















