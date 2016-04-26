//
//  FMDatabaseQueue+inTransaction.swift
//  Pods
//
//  Created by 钟建明 on 16/4/26.
//
//

import Foundation
import FMDB

public extension FMDatabaseQueue {
    public func intransaction(block: FMDatabase -> Bool) {
        inDatabase { db in
            db.beginTransaction()
            if block(db) {
                db.commit()
            } else {
                db.rollback()
            }
        }
    }
}

