//
//  SQLQuery.swift
//  SqlWrapper
//
//  Created by 钟建明 on 16/3/23.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class SQLQuerySpec: QuickSpec {
    override func spec() {
        describe("SQLQuery Spec") {
            it("select all columns") {
                let query = SQLQuery(table: "TableName")
                expect(query.build()) == "SELECT * FROM TableName"
            }
            
            it("selects columns") {
                let query = SQLQuery(table: "TableName", columns: ["FirstColumn", "SecondColumn"])
                expect(query.build()) == "SELECT \"FirstColumn\", \"SecondColumn\" FROM TableName"
            }
            
            it("select distinct") {
                let query = SQLQuery(table: "TableName")
                    .distinct()
                expect(query.build()) == "SELECT DISTINCT * FROM TableName"
            }
            
            context("group by") {
                it("one column") {
                    let query = SQLQuery(table: "TableName")
                        .groupBy("Column")
                    expect(query.build()) == "SELECT * FROM TableName GROUP BY \"Column\""
                }
                
                it("columns array") {
                    let query = SQLQuery(table: "TableName")
                        .groupBy(["Column1", "Column2"])
                    expect(query.build()) == "SELECT * FROM TableName GROUP BY \"Column1\", \"Column2\""
                }
                
                it("columns") {
                    let query = SQLQuery(table: "TableName")
                        .groupBy("Column1", "Column2")
                    expect(query.build()) == "SELECT * FROM TableName GROUP BY \"Column1\", \"Column2\""
                }
            }
            
            
            context("order by asc") {
                it("one column") {
                    let query = SQLQuery(table: "TableName")
                        .orderByAsc("Column")
                    expect(query.build()) == "SELECT * FROM TableName ORDER BY \"Column\" ASC"
                }
                
                it("columns array") {
                    let query = SQLQuery(table: "TableName")
                        .orderByAsc(["Column1", "Column2"])
                    expect(query.build()) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" ASC"
                }
                
                it("columns") {
                    let query = SQLQuery(table: "TableName")
                        .orderByAsc("Column1", "Column2")
                    expect(query.build()) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" ASC"
                }
            }
            
            context("order by desc") {
                it("one column") {
                    let query = SQLQuery(table: "TableName")
                        .orderByDesc("Column")
                    expect(query.build()) == "SELECT * FROM TableName ORDER BY \"Column\" DESC"
                }
                
                it("columns") {
                    let query = SQLQuery(table: "TableName")
                        .orderByDesc("Column1", "Column2")
                    expect(query.build()) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" DESC"
                }
                
                it("columns array") {
                    let query = SQLQuery(table: "TableName")
                        .orderByDesc(["Column1", "Column2"])
                    expect(query.build()) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" DESC"
                }
            }
            
            it("group by and order by") {
                let query = SQLQuery(table: "TableName")
                    .orderByAsc("OrderColumn1", "OrderColumn2")
                    .groupBy("GroupColumn1", "GroupColumn2")
                expect(query.build()) ==
                    "SELECT * FROM TableName GROUP BY \"GroupColumn1\", \"GroupColumn2\" ORDER BY \"OrderColumn1\", \"OrderColumn2\" ASC"
            }
            
            it("limit") {
                let query = SQLQuery(table: "TableName").limit(30)
                expect(query.build()) == "SELECT * FROM TableName LIMIT 30"
            }
            
            it("offset") {
                let query = SQLQuery(table: "TableName").offset(20)
                expect(query.build()) == "SELECT * FROM TableName OFFSET 20"
            }
            
            it("limit and offset") {
                let query = SQLQuery(table: "TableName").offset(20).limit(30)
                expect(query.build()) == "SELECT * FROM TableName LIMIT 30 OFFSET 20"
            }
            
            context("condition") {
                it("where by raw sql") {
                    let query = SQLQuery(table: "TableName")
                    .whereWithRaw { "Column == 1" }
                    
                    expect(query.build()) == "SELECT * FROM TableName WHERE Column == 1"
                }
                
                it("where by SQLQueryCondition") {
                    let condition = MockCondition(column: "Mock")
                    let query = SQLQuery(table: "TableName")
                    .whereWith { condition }
                    
                    expect(query.build()) == "SELECT * FROM TableName WHERE \(condition.toSql())"
                }
                
                it("where by SQLQueryCondition wrapper") {
                    let query: SQLQuery = SQLQuery(table: "TableName")
                        .whereWith { c in
                            c("Column")
                        }
                    expect(query.build()) == "SELECT * FROM TableName WHERE Column"
                }
            }
        }
    }
}

class MockCondition: SQLQueryCondition {
    override func toSql() -> String {
        return "mock"
    }
}




















