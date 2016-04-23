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