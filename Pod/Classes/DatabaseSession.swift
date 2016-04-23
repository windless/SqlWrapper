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
    
}


























