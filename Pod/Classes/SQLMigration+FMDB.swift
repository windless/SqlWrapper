//
//  SQLMigration+FMDB.swift
//  Pods
//
//  Created by 钟建明 on 16/4/23.
//
//

import Foundation
import FMDB

public extension FMDatabase {
    public func executeMigration(migration: SQLMigration) -> Bool {
        let sql = migration.buildScheme()
        NSLog(sql)
        return self.executeStatements(sql)
    }
    
    public func insert(activeRecord: ActiveRecord) -> Bool {
        do {
            let sql = activeRecord.insertSql
            NSLog(sql)
            try self.executeUpdate(sql, values: [])
            activeRecord.ID = Int(self.lastInsertRowId())
            return true
        } catch {
            return false
        }
    }
    
    public func update(activeRecord: ActiveRecord) -> Bool {
        do {
            let sql = activeRecord.updateSql
            NSLog(sql)
            try self.executeUpdate(sql, values: [])
            return true
        } catch {
            return false
        }
    }
    
    public func delete(activeRecord: ActiveRecord) -> Bool {
        do {
            let sql = activeRecord.deleteSql
            NSLog(sql)
            try self.executeUpdate(sql, values: [])
            return true
        } catch {
            return false
        }
    }
    
    public func delete(query: SQLQuery) -> Bool {
        do {
            let sql = query.buildDelete()
            NSLog(sql)
            try self.executeUpdate(sql, values: [])
            return true
        } catch {
            return false
        }
    }
}