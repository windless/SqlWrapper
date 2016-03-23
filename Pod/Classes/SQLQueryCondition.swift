//
//  SQLQueryCondition.swift
//  Pods
//
//  Created by 钟建明 on 16/3/23.
//
//

import Foundation

public class SQLQueryCondition {
    let column: String
    
    public init(column: String) {
        self.column = column
    }
    
    public func toSql() -> String {
        return column
    }
}






