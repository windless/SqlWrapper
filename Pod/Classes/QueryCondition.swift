//
//  QueryCondition.swift
//  Pods
//
//  Created by 钟建明 on 16/3/23.
//
//

import Foundation

public class QueryCondition: Statement {
    let column: String
    var conditionOperator: ConditionOperator?
    
    public init(column: String) {
        self.column = column
    }
    
    public var sqlString: String {
        guard let conditionOperator = self.conditionOperator else { return column }
        return self.column + conditionOperator.sqlString
    }
}

enum ConditionOperator: Statement {
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
    
    var sqlString: String {
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

public func == (left: QueryCondition, right: Any?) -> QueryCondition {
    if let right = right {
        left.conditionOperator = ConditionOperator.Eq(right)
    } else {
        left.conditionOperator = ConditionOperator.IsNull
    }
    return left
}

public func != (left: QueryCondition, right: Any?) -> QueryCondition {
    if let right = right {
        left.conditionOperator = ConditionOperator.NotEq(right)
    } else {
        left.conditionOperator = ConditionOperator.IsNotNull
    }
    return left
}

public func > (left: QueryCondition, right: Int) -> QueryCondition {
    left.conditionOperator = ConditionOperator.GT(right)
    return left
}

public func > (left: QueryCondition, right: Double) -> QueryCondition {
    left.conditionOperator = ConditionOperator.GT(right)
    return left
}

public func > (left: QueryCondition, right: NSDate) -> QueryCondition {
    left.conditionOperator = ConditionOperator.GT(right)
    return left
}

public func < (left: QueryCondition, right: Int) -> QueryCondition {
    left.conditionOperator = ConditionOperator.LT(right)
    return left
}

public func < (left: QueryCondition, right: Double) -> QueryCondition {
    left.conditionOperator = ConditionOperator.LT(right)
    return left
}

public func < (left: QueryCondition, right: NSDate) -> QueryCondition {
    left.conditionOperator = ConditionOperator.LT(right)
    return left
}

public func >= (left: QueryCondition, right: Int) -> QueryCondition {
    left.conditionOperator = ConditionOperator.GE(right)
    return left
}

public func >= (left: QueryCondition, right: Double) -> QueryCondition {
    left.conditionOperator = ConditionOperator.GE(right)
    return left
}

public func >= (left: QueryCondition, right: NSDate) -> QueryCondition {
    left.conditionOperator = ConditionOperator.GE(right)
    return left
}

public func <= (left: QueryCondition, right: Int) -> QueryCondition {
    left.conditionOperator = ConditionOperator.LE(right)
    return left
}

public func <= (left: QueryCondition, right: Double) -> QueryCondition {
    left.conditionOperator = ConditionOperator.LE(right)
    return left
}

public func <= (left: QueryCondition, right: NSDate) -> QueryCondition {
    left.conditionOperator = ConditionOperator.LE(right)
    return left
}

public func ~= (left: QueryCondition, right: String) -> QueryCondition {
    left.conditionOperator = ConditionOperator.Like(right)
    return left
}

public func ~> (left: QueryCondition, right: [Any]) -> QueryCondition {
    left.conditionOperator = ConditionOperator.In(right)
    return left
}

infix operator !~> {}
public func !~> (left: QueryCondition, right: [Any]) -> QueryCondition {
    left.conditionOperator = ConditionOperator.NotIn(right)
    return left
}

public func ~> (left: QueryCondition, right: (Any, Any)) -> QueryCondition {
    left.conditionOperator = ConditionOperator.Between(right.0, right.1)
    return left
}






