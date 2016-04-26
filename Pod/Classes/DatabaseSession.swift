//
//  DatabaseSession.swift
//  Pods
//
//  Created by 钟建明 on 16/4/23.
//
//

import Foundation
import FMDB

public class DatabaseSession {
    private let databaseQueue: FMDatabaseQueue
    
    public init(databasePath: String) {
        self.databaseQueue = FMDatabaseQueue(path: databasePath)
    }
    
    public func setup(migrations: [SQLMigration]) {
        databaseQueue.inDatabase { db in
            let version = UInt(db.userVersion())
            
            let sortedMigrations = migrations.filter { $0.version > version }
                .sort { $0.0.version < $0.1.version }
            
            for migration in sortedMigrations {
                db.beginTransaction()
                if db.executeMigration(migration) {
                    db.setUserVersion(UInt32(migration.version))
                    db.commit()
                } else {
                    db.rollback()
                    let error = db.lastError()
                    NSLog("Execute migration(version: \(migration.version) faled: \(error)")
                    return
                }
            }
        }
    }
}

// CRUD
public extension DatabaseSession {

    public func insert(activeRecord: ActiveRecord) -> Bool {
        var result = false
        databaseQueue.inDatabase { db in
            result = db.insert(activeRecord)
        }
        return result
    }
    
    public func update(activeRecord: ActiveRecord) -> Bool {
        var result = false
        databaseQueue.inDatabase { db in
            result = db.update(activeRecord)
        }
        return result
    }
    
    public func delete(activeRecord: ActiveRecord) -> Bool {
        var result = false
        databaseQueue.inDatabase { db in
            result = db.delete(activeRecord)
        }
        return result
    }
    
    public func inTransaction(block: FMDatabase -> Bool) -> Bool {
        var result = false
        databaseQueue.inDatabase { db in
            db.beginTransaction()
            if block(db) {
                db.commit()
                result = true
            } else {
                db.rollback()
                result = false
            }
        }
        return result
    }
    
    public func insert(activeRecords: ActiveRecord...) -> Bool {
        return insert(activeRecords)
    }
    
    public func insert(activeRecords: [ActiveRecord]) -> Bool {
        return inTransaction { db in
            for activeRecord in activeRecords {
                if !db.insert(activeRecord) {
                    return false
                }
            }
            return true
        }
    }
    
    public func update(activeRecords: [ActiveRecord]) -> Bool {
        return inTransaction { db in
            for activeRecord in activeRecords {
                if !db.update(activeRecord) {
                    return false
                }
            }
            return true
        }
    }
    
    public func update(activeRecords: ActiveRecord...) -> Bool {
        return update(activeRecords)
    }
    
    public func delete(activeRecords: [ActiveRecord]) -> Bool {
        return inTransaction { db in
            for activeRecord in activeRecords {
                if !db.delete(activeRecord) {
                    return false
                }
            }
            return true
        }
    }
    
    public func delete(activeRecords: ActiveRecord...) -> Bool {
        return delete(activeRecords)
    }
    
    public func delete<T: ActiveRecord>(type: T.Type, query: SQLQuery) -> Bool {
        var result = false
        self.databaseQueue.inDatabase { db in
            result = db.delete(query)
        }
        return result
    }
    
    public func delete<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryComposedCondition) -> Bool {
        let query = SQLQuery(table: type.table)
        query.whereWith(whereBlock)
        return delete(type, query: query)
    }
    
    public func delete<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryCondition) -> Bool {
        let query = SQLQuery(table: type.table)
        query.whereWith(whereBlock)
        return delete(type, query: query)
    }
}

// Query
public extension DatabaseSession {
    public func queryAll<T: ActiveRecord>(type: T.Type) -> [T] {
        let activeRecord = type.init()
        let columns = ["ID"] + activeRecord.properties.map { $0.0 }
        let query = SQLQuery(table: type.table, columns: columns)
        
        return queryList(type, query: query)
    }
    
    public func queryList<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryComposedCondition) -> [T] {
        let activeRecord = type.init()
        let columns = ["ID"] + activeRecord.properties.map { $0.0 }
        let query = SQLQuery(table: type.table, columns: columns)
        query.whereWith(whereBlock)
        
        return queryList(type, query: query)
    }
    
    public func queryList<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryCondition) -> [T] {
        let activeRecord = type.init()
        let columns = ["ID"] + activeRecord.properties.map { $0.0 }
        let query = SQLQuery(table: type.table, columns: columns)
        query.whereWith(whereBlock)
        
        return queryList(type, query: query)
    }
    
    public func queryList<T: ActiveRecord>(type: T.Type, query: SQLQuery) -> [T] {
        let sql = query.build()
        
        var result = [T]()
        self.databaseQueue.inDatabase { db in
            do {
                NSLog(sql)
                let fmResutlSets = try db.executeQuery(sql, values: [])
                while fmResutlSets.next() {
                    let activeRecord: T? = type.map(ResultSetImpl(resultSets: fmResutlSets))
                    if let a = activeRecord {
                        result.append(a)
                    }
                }
            } catch {
                
            }
        }
        return result
    }
    
    public func querySingle<T: ActiveRecord>(type: T.Type, query: SQLQuery) -> T? {
        let sql = query.build()
        
        var result: T? = nil
        self.databaseQueue.inDatabase { db in
            do {
                NSLog(sql)
                let fmResutlSets = try db.executeQuery(sql, values: [])
                if fmResutlSets.next() {
                    let activeRecord: T? = type.map(ResultSetImpl(resultSets: fmResutlSets))
                    result = activeRecord
                }
            } catch {
                
            }
        }
        return result
    }
    
    public func querySingle<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryComposedCondition) -> T? {
        let activeRecord = type.init()
        let columns = ["ID"] + activeRecord.properties.map { $0.0 }
        let query = SQLQuery(table: type.table, columns: columns)
        query.whereWith(whereBlock).limit(1)
        
        return querySingle(type, query: query)
    }
    
    public func querySingle<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryCondition) -> T? {
        let activeRecord = type.init()
        let columns = ["ID"] + activeRecord.properties.map { $0.0 }
        let query = SQLQuery(table: type.table, columns: columns)
        query.whereWith(whereBlock).limit(1)
        
        return querySingle(type, query: query)
    }
    
    public func queryCount<T: ActiveRecord>(type: T.Type, query: SQLQuery) -> Int {
        let sql = query.buildCount()
        var result: Int = 0
        self.databaseQueue.inDatabase { db in
            do {
                NSLog(sql)
                let resultSet = try db.executeQuery(sql, values: [])
                if resultSet.next() {
                    result = Int(resultSet.intForColumnIndex(0))
                }
                
            } catch {
                
            }
            
        }
        return result
    }
    
    public func queryCount<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryComposedCondition) -> Int {
        let query = SQLQuery(table: type.table, columns: ["ID"])
        query.whereWith(whereBlock).limit(1)
        return queryCount(type, query: query)
    }
    
    public func queryCount<T: ActiveRecord>(type: T.Type, whereBlock: SQLQuery.ConditionGenerator -> SQLQueryCondition) -> Int {
        let query = SQLQuery(table: type.table, columns: ["ID"])
        query.whereWith(whereBlock).limit(1)
        return queryCount(type, query: query)
    }
    
    
}

private class ResultSetImpl: ResultSet {
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


























