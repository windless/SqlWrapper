//
//  SQLQueryComposedCondition.swift
//  Pods
//
//  Created by 钟建明 on 16/3/24.
//
//

import Foundation

public class QueryComposedCondition: Statement {
    enum Operator: Statement {
        case Or, And
        
        var sqlString: String {
            switch self {
            case .Or:
                return "OR"
            case .And:
                return "AND"
            }
        }
    }
    
    let left: Statement
    let right: Statement
    let opet: Operator
    
    init(left: Statement, right: Statement, opet: Operator) {
        self.left = left
        self.right = right
        self.opet = opet
    }
    
    public var sqlString: String {
        return "(\(left.sqlString) \(opet.sqlString) \(right.sqlString))"
    }
}

public func || (left: Statement, right: Statement) -> QueryComposedCondition {
    return QueryComposedCondition(left: left, right: right, opet: .Or)
}

public func && (left: Statement, right: Statement) -> QueryComposedCondition {
    return QueryComposedCondition(left: left, right: right, opet: .And)
}















