//
//  UpdateStatement.swift
//  Pods
//
//  Created by 钟建明 on 16/4/27.
//
//

import Foundation
import FMDB

protocol UpdateStatement {
    func execute(db: FMDatabase) -> Bool
}

protocol QueryStatement {
    func execute(db: FMDatabase) -> ResultSet?
}