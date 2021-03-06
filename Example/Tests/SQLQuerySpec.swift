//
//  SQLQuery.swift
//  SqlWrapper
//
//  Created by A.Z on 16/3/23.
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
                let query = QuerySelect(table: "TableName")
                expect(query.sqlString) == "SELECT * FROM TableName;"
            }
            
            it("selects columns") {
                let query = QuerySelect(table: "TableName", columns: ["FirstColumn", "SecondColumn"])
                expect(query.sqlString) == "SELECT \"FirstColumn\", \"SecondColumn\" FROM TableName;"
            }
            
            it("select distinct") {
                let query = QuerySelect(table: "TableName")
                    .distinct()
                expect(query.sqlString) == "SELECT DISTINCT * FROM TableName;"
            }
            
            context("group by") {
                it("one column") {
                    let query = QuerySelect(table: "TableName")
                        .groupBy("Column")
                    expect(query.sqlString) == "SELECT * FROM TableName GROUP BY \"Column\";"
                }
                
                it("columns array") {
                    let query = QuerySelect(table: "TableName")
                        .groupBy(["Column1", "Column2"])
                    expect(query.sqlString) == "SELECT * FROM TableName GROUP BY \"Column1\", \"Column2\";"
                }
                
                it("columns") {
                    let query = QuerySelect(table: "TableName")
                        .groupBy("Column1", "Column2")
                    expect(query.sqlString) == "SELECT * FROM TableName GROUP BY \"Column1\", \"Column2\";"
                }
            }
            
            
            context("order by asc") {
                it("one column") {
                    let query = QuerySelect(table: "TableName")
                        .orderByAsc("Column")
                    expect(query.sqlString) == "SELECT * FROM TableName ORDER BY \"Column\" ASC;"
                }
                
                it("columns array") {
                    let query = QuerySelect(table: "TableName")
                        .orderByAsc(["Column1", "Column2"])
                    expect(query.sqlString) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" ASC;"
                }
                
                it("columns") {
                    let query = QuerySelect(table: "TableName")
                        .orderByAsc("Column1", "Column2")
                    expect(query.sqlString) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" ASC;"
                }
            }
            
            context("order by desc") {
                it("one column") {
                    let query = QuerySelect(table: "TableName")
                        .orderByDesc("Column")
                    expect(query.sqlString) == "SELECT * FROM TableName ORDER BY \"Column\" DESC;"
                }
                
                it("columns") {
                    let query = QuerySelect(table: "TableName")
                        .orderByDesc("Column1", "Column2")
                    expect(query.sqlString) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" DESC;"
                }
                
                it("columns array") {
                    let query = QuerySelect(table: "TableName")
                        .orderByDesc(["Column1", "Column2"])
                    expect(query.sqlString) == "SELECT * FROM TableName ORDER BY \"Column1\", \"Column2\" DESC;"
                }
            }
            
            it("group by and order by") {
                let query = QuerySelect(table: "TableName")
                    .orderByAsc("OrderColumn1", "OrderColumn2")
                    .groupBy("GroupColumn1", "GroupColumn2")
                expect(query.sqlString) ==
                    "SELECT * FROM TableName GROUP BY \"GroupColumn1\", \"GroupColumn2\" ORDER BY \"OrderColumn1\", \"OrderColumn2\" ASC;"
            }
            
            it("limit") {
                let query = QuerySelect(table: "TableName").limit(30)
                expect(query.sqlString) == "SELECT * FROM TableName LIMIT 30;"
            }
            
            it("offset") {
                let query = QuerySelect(table: "TableName").offset(20)
                expect(query.sqlString) == "SELECT * FROM TableName OFFSET 20;"
            }
            
            it("limit and offset") {
                let query = QuerySelect(table: "TableName").offset(20).limit(30)
                expect(query.sqlString) == "SELECT * FROM TableName LIMIT 30 OFFSET 20;"
            }
            
            context("condition") {
                it("where by raw sql") {
                    let query = QuerySelect(table: "TableName")
                    .whereWithRaw { "Column == 1" }
                    
                    expect(query.sqlString) == "SELECT * FROM TableName WHERE Column == 1;"
                }
                
                it("where by SQLQueryCondition wrapper") {
                    let query = QuerySelect(table: "TableName")
                        .whereWith { c in
                            c("Column")
                        }
                    expect(query.sqlString) == "SELECT * FROM TableName WHERE Column;"
                }
            }
            
            it("selects") {
                let query = QuerySelect(table: "Table")
                    .whereWith { c in
                        c("c1") == 1 && c("c2") == "hello"
                    }
                expect(query.sqlString) == "SELECT * FROM Table WHERE (c1 = 1 AND c2 = 'hello');"
            }
            
            it("selects count") {
                let query = QueryCount(table: "Table")
                    .whereWith { c in
                        c("c1") == 1
                    }
                expect(query.sqlString) == "SELECT count(*) FROM Table WHERE c1 = 1;"
                
            }
            
            it("deletes records") {
                let query = QueryDelete(table: "Table")
                    .whereWith { c in
                        c("c1") == 1
                    }
                expect(query.sqlString) ==
                    "DELETE FROM Table WHERE c1 = 1;"
            }
            
            it("update sets") {
                let query = QueryUpdate(table: "Table", set: ["c1": 1, "c2": "hello"])
                    .whereWith { c in
                        c("c1") == 1
                    }
                expect(query.sqlString) ==
                    "UPDATE Table SET c2 = 'hello', c1 = 1 WHERE c1 = 1;"
            }
            
            context("query ActiveRecord") {
                it("select") {
                    let query = QuerySelect(type: Student.self).whereWith { c in
                        c("name") == "windless"
                    }
                    expect(query.sqlString) ==
                        "SELECT \"ID\", \"name\", \"age\", \"classId\" FROM Student WHERE name = 'windless';"
                }
                
                it("select with join") {
                    let query = QuerySelect(type: Student.self)
                        .join(Class.self, on: ("Student.classId", "Class.ID"))
                    expect(query.sqlString) ==
                        "SELECT \"Student.ID\" AS \"Student.ID\", \"Student.name\" AS \"Student.name\", \"Student.age\" AS \"Student.age\", \"Student.classId\" AS \"Student.classId\", \"Class.ID\" AS \"Class.ID\", \"Class.name\" AS \"Class.name\" FROM Student JOIN Class ON Student.classId = Class.ID;"
                }
            }
        }
    }
}

class MockCondition: QueryCondition {
    override var sqlString: String {
        return "mock"
    }
}

class Student: ActiveRecord {
    var name: String
    var age: Int
    var classId: Int?
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    required init() {
        name = ""
        age = 0
    }
}

class Class: ActiveRecord {
    var name: String = ""
    
    init(name: String) {
        self.name = name
    }
    
    required init() {
    }
}




















