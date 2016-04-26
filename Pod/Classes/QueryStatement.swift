//
//  SQLQuery.swift
//  Pods
//
//  Created by 钟建明 on 16/3/23.
//
//

import Foundation
import FMDB

enum QueryOrderBy: Statement {
    case ASC([String])
    case DESC([String])
    
    var sqlString: String {
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

public class Query: Statement {
    let table: String
    var selectColumns: [String]?
    var isDistinct: Bool = false
    var groupColumns: [String]?
    var orderBy: QueryOrderBy?
    var limit: Int?
    var offset: Int?
    var whereCondition: String?
    
    public init(table: String, columns: [String]? = nil) {
        self.table = table
        self.selectColumns = columns
    }
    
    public var sqlString: String {
        fatalError()
    }
    
    public func distinct() -> Query {
        self.isDistinct = true
        return self
    }
    
    public func groupBy(columns: String...) -> Query {
        self.groupBy(columns)
        return self
    }
    
    public func groupBy(columns: [String]) -> Query {
        self.groupColumns = columns
        return self
    }
    
    public func orderByAsc(columns: String...) -> Query {
        self.orderByAsc(columns)
        return self
    }
    
    public func orderByAsc(columns: [String]) -> Query {
        self.orderBy = QueryOrderBy.ASC(columns)
        return self
    }
    
    public func orderByDesc(columns: String...) -> Query {
        self.orderByDesc(columns)
        return self
    }
    
    public func orderByDesc(columns: [String]) -> Query {
        self.orderBy = QueryOrderBy.DESC(columns)
        return self
    }
    
    public func limit(count: Int) -> Query {
        self.limit = count
        return self
    }
    
    public func offset(count: Int) -> Query {
        self.offset = count
        return self
    }
    
    public func whereWithRaw(block: Void -> String) -> Query {
        self.whereCondition = block()
        return self
    }
    
    public func whereWith(block: Void -> QueryCondition) -> Query {
        self.whereCondition = block().sqlString
        return self
    }
    
    public typealias ConditionGenerator = String -> QueryCondition
    public typealias ConditionBlock = ConditionGenerator -> Statement
    
    public func whereWith(block: (ConditionBlock)?) -> Query {
        let conditionGenerator: ConditionGenerator = { column in QueryCondition(column: column) }
        self.whereCondition = block?(conditionGenerator).sqlString
        return self
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
        return self.orderBy?.sqlString ?? ""
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

public class QuerySelect: Query {
    
    public convenience init(type: ActiveRecord.Type) {
        let activeRecord = type.init()
        let columns = ["ID"] + activeRecord.properties.map { $0.0 }
        self.init(table: type.table, columns: columns)
    }
    
    public override var sqlString: String {
        return "SELECT\(distinctToken) \(columnsToken) FROM \(self.table)\(whereToken)\(groupByToken)\(orderByToken)\(limitToken)\(offsetToken);"
    }
}

public class QueryCount: Query {
    
    public convenience init(type: ActiveRecord.Type) {
        self.init(table: type.table, columns: [type.primaryKey])
    }
    
    public override var sqlString: String {
        return "SELECT count(*) FROM \(self.table)\(whereToken)\(groupByToken)\(orderByToken)\(limitToken)\(offsetToken);"
    }
}

public class QueryDelete: Query {
    public override var sqlString: String {
        return "DELETE FROM \(table)\(whereToken);"
    }
}

public class QueryUpdate: Query {
    private let set: [String: Any?]
    
    public init(table: String, set: [String: Any?]) {
        self.set = set
        super.init(table: table)
    }
    
    public override var sqlString: String {
        let setToken = set
            .map { "\($0) = \(SQLValueTransformer.transform($1))" }
            .joinWithSeparator(", ")
        return "UPDATE \(table) SET \(setToken)\(whereToken);"
    }
}



















