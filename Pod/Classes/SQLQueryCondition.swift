//
//  SQLQueryCondition.swift
//  Pods
//
//  Created by 钟建明 on 16/3/23.
//
//

import Foundation

public class SQLQueryCondition: SQLSqlable {
    let column: String
    var conditionOperator: SQLQueryConditionOperator?
    
    public init(column: String) {
        self.column = column
    }
    
    public func toSql() -> String {
        guard let conditionOperator = self.conditionOperator else { return column }
        return self.column + conditionOperator.toSql()
    }
}

enum SQLQueryConditionOperator {
    case Eq(Any)
    case NotEq(Any)
    case IsNull
    case IsNotNull
    case GT(Any)
    case LT(Any)
    case GE(Any)
    case LE(Any)
    case Like(String)
    case In([Any])
    case NotIn([Any])
    case Between(Any, Any)
    
    func toSql() -> String {
        switch self {
        case let .Eq(value):
            return " = \(sqlValue(value))"
        case let .NotEq(value):
            return " != \(sqlValue(value))"
        case .IsNull:
            return " IS NULL"
        case .IsNotNull:
            return " IS NOT NULL"
        case let .GT(value):
            return " > \(sqlValue(value))"
        case let .LT(value):
            return " < \(sqlValue(value))"
        case let .GE(value):
            return " >= \(sqlValue(value))"
        case let .LE(value):
            return " <= \(sqlValue(value))"
        case let .Like(value):
            return " LIKE \(sqlValue(value))"
        case let .In(values):
            let token = values.map { sqlValue($0) }.joinWithSeparator(", ")
            return " IN (\(token))"
        case let .NotIn(values):
            let token = values.map { sqlValue($0) }.joinWithSeparator(", ")
            return " NOT IN (\(token))"
        case let .Between(value1, value2):
            return " BETWEEN \(value1) AND \(value2)"
        }
    }
    
    private func sqlValue(value: Any?) -> String {
        return SQLValueTransformer.transform(value)
    }
}

public func == (left: SQLQueryCondition, right: Any?) -> SQLQueryCondition {
    if let right = right {
        left.conditionOperator = SQLQueryConditionOperator.Eq(right)
    } else {
        left.conditionOperator = SQLQueryConditionOperator.IsNull
    }
    return left
}

public func != (left: SQLQueryCondition, right: Any?) -> SQLQueryCondition {
    if let right = right {
        left.conditionOperator = SQLQueryConditionOperator.NotEq(right)
    } else {
        left.conditionOperator = SQLQueryConditionOperator.IsNotNull
    }
    return left
}

public func > (left: SQLQueryCondition, right: Int) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.GT(right)
    return left
}

public func > (left: SQLQueryCondition, right: Double) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.GT(right)
    return left
}

public func < (left: SQLQueryCondition, right: Int) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.LT(right)
    return left
}

public func < (left: SQLQueryCondition, right: Double) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.LT(right)
    return left
}

public func >= (left: SQLQueryCondition, right: Int) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.GE(right)
    return left
}

public func >= (left: SQLQueryCondition, right: Double) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.GE(right)
    return left
}

public func <= (left: SQLQueryCondition, right: Int) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.LE(right)
    return left
}

public func <= (left: SQLQueryCondition, right: Double) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.LE(right)
    return left
}

public func ~= (left: SQLQueryCondition, right: String) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.Like(right)
    return left
}

public func ~> (left: SQLQueryCondition, right: [Any]) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.In(right)
    return left
}

infix operator !~> {}
public func !~> (left: SQLQueryCondition, right: [Any]) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.NotIn(right)
    return left
}

public func ~> (left: SQLQueryCondition, right: (Any, Any)) -> SQLQueryCondition {
    left.conditionOperator = SQLQueryConditionOperator.Between(right.0, right.1)
    return left
}






