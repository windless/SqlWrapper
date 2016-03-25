//
//  SQLQueryComposedCondition.swift
//  Pods
//
//  Created by 钟建明 on 16/3/24.
//
//

import Foundation

public protocol SQLSqlable {
    func toSql() -> String
}

public class SQLQueryComposedCondition: SQLSqlable {
    enum Operator {
        case Or, And
        
        func toSql() -> String {
            switch self {
            case .Or:
                return "OR"
            case .And:
                return "AND"
            }
        }
    }
    
    let left: SQLSqlable
    let right: SQLSqlable
    let opet: Operator
    
    init(left: SQLSqlable, right: SQLSqlable, opet: Operator) {
        self.left = left
        self.right = right
        self.opet = opet
    }
    
    public func toSql() -> String {
        return "(\(left.toSql()) \(opet.toSql()) \(right.toSql()))"
    }
}

public func || (left: SQLSqlable, right: SQLSqlable) -> SQLQueryComposedCondition {
    return SQLQueryComposedCondition(left: left, right: right, opet: .Or)
}

//public func || (left: SQLQueryCondition, right: SQLQueryComposedCondition) -> SQLQueryComposedCondition {
//    return SQLQueryComposedCondition()
//}
//
//public func || (left: SQLQueryComposedCondition, right: SQLQueryCondition) -> SQLQueryComposedCondition {
//    return SQLQueryComposedCondition()
//}
//
//public func || (left: SQLQueryComposedCondition, right: SQLQueryComposedCondition) -> SQLQueryComposedCondition {
//    return SQLQueryComposedCondition()
//}

public func && (left: SQLSqlable, right: SQLSqlable) -> SQLQueryComposedCondition {
    return SQLQueryComposedCondition(left: left, right: right, opet: .And)
}















