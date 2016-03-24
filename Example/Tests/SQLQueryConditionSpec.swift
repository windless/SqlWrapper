//
//  SQLQueryConditionSpec.swift
//  SqlWrapper
//
//  Created by A.Z on 16/3/23.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class SQLQueryConditionSpec: QuickSpec {
    override func spec() {
        describe("SQLQueryCondition") {
            var condition: SQLQueryCondition!
            
            beforeEach {
                condition = SQLQueryCondition(column: "c")
            }
            
            describe("== value") {
                it("== integer") {
                    let sql = (SQLQueryCondition(column: "column") == 1).toSql()
                    expect(sql) == "column = 1"
                }
                
                it("== real") {
                    let sql = (SQLQueryCondition(column: "column") == 1.0).toSql()
                    expect(sql) == "column = 1.0"
                }
                
                it("== nil") {
                    let sql = (SQLQueryCondition(column: "column") == nil).toSql()
                    expect(sql) == "column IS NULL"
                }
                
                it("== text") {
                    let sql1 = (SQLQueryCondition(column: "column") == "hello").toSql()
                    expect(sql1) == "column = 'hello'"
                    
                    let sql2 = (SQLQueryCondition(column: "column") == "he'l'lo").toSql()
                    expect(sql2) == "column = 'he''l''lo'"
                }
                
                it("== bool") {
                    let sql1 = (SQLQueryCondition(column: "column") == true).toSql()
                    expect(sql1) == "column = 1"
                    
                    let sql2 = (SQLQueryCondition(column: "column") == false).toSql()
                    expect(sql2) == "column = 0"
                }
            }
            
            it("!= value") {
                let sql1 = (SQLQueryCondition(column: "column") != 1).toSql()
                expect(sql1) == "column != 1"
                
                let sql2 = (SQLQueryCondition(column: "column") != nil).toSql()
                expect(sql2) == "column IS NOT NULL"
                
            }
            
            it("> value") {
                let sql1 = (condition > 1).toSql()
                expect(sql1) == "c > 1"
                
                let sql2 = (condition > 1.0).toSql()
                expect(sql2) == "c > 1.0"
            }
            
            it("< value") {
                let sql1 = (condition < 1).toSql()
                expect(sql1) == "c < 1"
                
                let sql2 = (condition < 1.0).toSql()
                expect(sql2) == "c < 1.0"
            }
            
            it(">= value") {
                let sql1 = (condition >= 1).toSql()
                expect(sql1) == "c >= 1"
                
                let sql2 = (condition >= 1.0).toSql()
                expect(sql2) == "c >= 1.0"
            }
            
            it("<= value") {
                let sql1 = (condition <= 1).toSql()
                expect(sql1) == "c <= 1"
                
                let sql2 = (condition <= 1.0).toSql()
                expect(sql2) == "c <= 1.0"
            }
            
            it("like value") {
                let sql = (condition ~= "abc").toSql()
                expect(sql) == "c LIKE 'abc'"
            }
            
            it("in array") {
                let sql = (condition ~> [1, 2, 3]).toSql()
                expect(sql) == "c IN (1, 2, 3)"
            }
            
            it("not in array") {
                let sql = (condition !~> [1, 2, 3]).toSql()
                expect(sql) == "c NOT IN (1, 2, 3)"
            }
            
            it("between value and value") {
                let sql = (condition ~> (1, 2)).toSql()
                expect(sql) == "c BETWEEN 1 AND 2"
            }
        }
    }
}




















