//
//  SQLQuery.swift
//  Pods
//
//  Created by 钟建明 on 16/3/23.
//
//

import Foundation

enum SQLQueryOrderBy {
    case ASC([String])
    case DESC([String])
    
    func toSql() -> String {
        switch self {
        case .ASC(let columns):
            return " ORDER BY \(columnsToken(columns)) ASC"
        case .DESC(let columns):
            return " ORDER BY \(columnsToken(columns)) DESC"
        }
    }
    
    private func columnsToken(columns: [String]) -> String {
        return columns.map { "\"\($0)\"" }.joinWithSeparator(", ")
    }
}

public class SQLQuery {
    let table: String
    var selectColumns: [String]?
    var isDistinct: Bool = false
    var groupColumns: [String]?
    var orderBy: SQLQueryOrderBy?
    var limit: Int?
    var offset: Int?
    var whereCondition: String?
    
    public init(table: String, columns: [String]? = nil) {
        self.table = table
        self.selectColumns = columns
    }
    
    public func distinct() -> SQLQuery {
        self.isDistinct = true
        return self
    }
    
    public func groupBy(columns: String...) -> SQLQuery {
        self.groupBy(columns)
        return self
    }
    
    public func groupBy(columns: [String]) -> SQLQuery {
        self.groupColumns = columns
        return self
    }
    
    public func orderByAsc(columns: String...) -> SQLQuery {
        self.orderByAsc(columns)
        return self
    }
    
    public func orderByAsc(columns: [String]) -> SQLQuery {
        self.orderBy = SQLQueryOrderBy.ASC(columns)
        return self
    }
    
    public func orderByDesc(columns: String...) -> SQLQuery {
        self.orderByDesc(columns)
        return self
    }
    
    public func orderByDesc(columns: [String]) -> SQLQuery {
        self.orderBy = SQLQueryOrderBy.DESC(columns)
        return self
    }
    
    public func limit(count: Int) -> SQLQuery {
        self.limit = count
        return self
    }
    
    public func offset(count: Int) -> SQLQuery {
        self.offset = count
        return self
    }
    
    public func whereWithRaw(block: Void -> String) -> SQLQuery {
        self.whereCondition = block()
        return self
    }
    
    public func whereWith(block: Void -> SQLQueryCondition) -> SQLQuery {
        self.whereCondition = block().toSql()
        return self
    }
    
    public typealias ConditionGenerator = String -> SQLQueryCondition
    public func whereWith(block: (ConditionGenerator -> SQLQueryCondition)?) -> SQLQuery {
        let conditionGenerator: ConditionGenerator = { column in SQLQueryCondition(column: column) }
        self.whereCondition = block?(conditionGenerator).toSql()
        return self
    }
    
    public func whereWith(block: (ConditionGenerator -> SQLQueryComposedCondition)?) -> SQLQuery {
        let conditionGenerator: ConditionGenerator = { column in SQLQueryCondition(column: column) }
        self.whereCondition = block?(conditionGenerator).toSql()
        return self
    }
    
    public func build() -> String {
        return "SELECT\(distinctToken) \(columnsToken) FROM \(self.table)\(whereToken)\(groupByToken)\(orderByToken)\(limitToken)\(offsetToken);"
    }
    
    public func buildCount() -> String {
        return "SELECT count(*) FROM \(self.table)\(whereToken)\(groupByToken)\(orderByToken)\(limitToken)\(offsetToken);"
    }
    
    public func buildDelete() -> String {
        return "DELETE FROM \(table)\(whereToken);"
    }
    
    private var columnsToken: String {
        return self.selectColumns?.map { "\"\($0)\"" }.joinWithSeparator(", ") ?? "*"
    }
    
    private var distinctToken: String {
        return self.isDistinct ? " DISTINCT" : ""
    }
    
    private var groupByToken: String {
        if let groupColumns = self.groupColumns {
            let columns = groupColumns.map { "\"\($0)\"" }.joinWithSeparator(", ")
            return " GROUP BY \(columns)"
        } else {
            return ""
        }
    }
    
    private var orderByToken: String {
        return self.orderBy?.toSql() ?? ""
    }
    
    private var limitToken: String {
        guard let limit = self.limit else { return "" }
        return " LIMIT \(limit)"
    }
    
    private var offsetToken: String {
        guard let offset = self.offset else { return "" }
        return " OFFSET \(offset)"
    }
    
    private var whereToken: String {
        guard let whereCondition = self.whereCondition else { return "" }
        return " WHERE \(whereCondition)"
    }
}



















