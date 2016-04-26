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
        describe("QueryCondition") {
            var condition: QueryCondition!
            
            beforeEach {
                condition = QueryCondition(column: "c")
            }
            
            describe("== value") {
                it("== integer") {
                    let sql = (QueryCondition(column: "column") == 1).sqlString
                    expect(sql) == "column = 1"
                }
                
                it("== real") {
                    let sql = (QueryCondition(column: "column") == 1.0).sqlString
                    expect(sql) == "column = 1.0"
                }
                
                it("== nil") {
                    let sql = (QueryCondition(column: "column") == nil).sqlString
                    expect(sql) == "column IS NULL"
                }
                
                it("== text") {
                    let sql1 = (QueryCondition(column: "column") == "hello").sqlString
                    expect(sql1) == "column = 'hello'"
                    
                    let sql2 = (QueryCondition(column: "column") == "he'l'lo").sqlString
                    expect(sql2) == "column = 'he''l''lo'"
                }
                
                it("== bool") {
                    let sql1 = (QueryCondition(column: "column") == true).sqlString
                    expect(sql1) == "column = 1"
                    
                    let sql2 = (QueryCondition(column: "column") == false).sqlString
                    expect(sql2) == "column = 0"
                }
            }
            
            it("!= value") {
                let sql1 = (QueryCondition(column: "column") != 1).sqlString
                expect(sql1) == "column != 1"
                
                let sql2 = (QueryCondition(column: "column") != nil).sqlString
                expect(sql2) == "column IS NOT NULL"
                
            }
            
            it("> value") {
                let sql1 = (condition > 1).sqlString
                expect(sql1) == "c > 1"
                
                let sql2 = (condition > 1.0).sqlString
                expect(sql2) == "c > 1.0"
            }
            
            it("< value") {
                let sql1 = (condition < 1).sqlString
                expect(sql1) == "c < 1"
                
                let sql2 = (condition < 1.0).sqlString
                expect(sql2) == "c < 1.0"
            }
            
            it(">= value") {
                let sql1 = (condition >= 1).sqlString
                expect(sql1) == "c >= 1"
                
                let sql2 = (condition >= 1.0).sqlString
                expect(sql2) == "c >= 1.0"
            }
            
            it("<= value") {
                let sql1 = (condition <= 1).sqlString
                expect(sql1) == "c <= 1"
                
                let sql2 = (condition <= 1.0).sqlString
                expect(sql2) == "c <= 1.0"
            }
            
            it("like value") {
                let sql = (condition ~= "abc").sqlString
                expect(sql) == "c LIKE 'abc'"
            }
            
            it("in array") {
                let sql = (condition ~> [1, 2, 3]).sqlString
                expect(sql) == "c IN (1, 2, 3)"
            }
            
            it("not in array") {
                let sql = (condition !~> [1, 2, 3]).sqlString
                expect(sql) == "c NOT IN (1, 2, 3)"
            }
            
            it("between value and value") {
                let sql = (condition ~> (1, 2)).sqlString
                expect(sql) == "c BETWEEN 1 AND 2"
            }
        }
    }
}




















