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
    public func ceateTable(table: String, block: CreateTableStatement -> Void) -> Bool {
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
            let activeRecord: T? = type.map(ResultSetImpl(resultSets: resultSet))
            if let a = activeRecord {
                result.append(a)
            }
        }
        return result
    }
}

public extension FMDatabase {
    public func insert(activeRecord: ActiveRecord) -> Bool {
        do {
            let statement = ActiveRecordInsertStatement(activeRecord: activeRecord)
            try self.executeUpdate(statement.sqlString, values: [])
            if activeRecord.dynamicType.primaryKey == "ID" {
                activeRecord.ID = Int(self.lastInsertRowId())
            }
            return true
        } catch {
            return false
        }
    }
    
    public func insert(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !insert(activeRecord) {
                return false
            }
        }
        return true
    }
    
    public func update(activeRecord: ActiveRecord) -> Bool {
        do {
            let statement = ActiveRecordUpdateStatement(activeRecord: activeRecord)
            try self.executeUpdate(statement.sqlString, values: [])
            return true
        } catch {
            return false
        }
    }
    
    public func update(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !update(activeRecord) {
                return false
            }
        }
        return true
    }
    
    public func insertOrUpdate(activeRecord: ActiveRecord) -> Bool {
        let count = selectCount(activeRecord.dynamicType) { c in
            c(activeRecord.dynamicType.primaryKey) == activeRecord.primaryKeyValue
        }
        if count > 0 {
            update(activeRecord)
        } else {
            insert(activeRecord)
        }
        return true
    }
    
    public func insertOrUpdate(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !insertOrUpdate(activeRecord) {
                return false
            }
        }
        return true
    }
    
    public func delete(activeRecord: ActiveRecord) -> Bool {
        do {
            let statement = ActiveRecordDeleteStatement(activeRecord: activeRecord)
            try self.executeUpdate(statement.sqlString, values: [])
            return true
        } catch {
            return false
        }
    }
    
    public func delete(activeRecords: [ActiveRecord]) -> Bool {
        for activeRecord in activeRecords {
            if !delete(activeRecord) {
                return false
            }
        }
        return true
    }
}


class ResultSetImpl: ResultSet {
    let fmResultSets: FMResultSet
    
    init(resultSets: FMResultSet) {
        self.fmResultSets = resultSets
    }
    
    func integer(column: String) -> Int? {
        return Int(fmResultSets.intForColumn(column))
    }
    
    func bool(column: String) -> Bool? {
        return fmResultSets.boolForColumn(column)
    }
    
    func string(column: String) -> String? {
        return fmResultSets.stringForColumn(column)
    }
    
    func double(column: String) -> Double? {
        return fmResultSets.doubleForColumn(column)
    }
    
    func date(column: String) -> NSDate? {
        return fmResultSets.dateForColumn(column)
    }
    
    func data(column: String) -> NSData? {
        return fmResultSets.dataForColumn(column)
    }
}


















