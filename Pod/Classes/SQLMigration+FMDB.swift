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
}