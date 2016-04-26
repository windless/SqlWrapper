//
//  SQLQueryComposedCondition.swift
//  SqlWrapper
//
//  Created by 钟建明 on 16/3/24.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class SQLQueryComposedConditionSpec: QuickSpec {
    override func spec() {
        describe("SQLQueryComposedCondition") {
            var condition1: QueryCondition!
            var condition2: QueryCondition!
            beforeEach {
                condition1 = QueryCondition(column: "c1") == 1
                condition2 = QueryCondition(column: "c2") == 2
            }
            
            it("or") {
                let sql = (condition1 || condition2).sqlString
                expect(sql) == "(c1 = 1 OR c2 = 2)"
            }
            
            it("and") {
                let sql = (condition1 && condition2).sqlString
                expect(sql) == "(c1 = 1 AND c2 = 2)"
            }
            
            it("parentheses") {
                let sql1 = (condition1 || (condition1 && condition2)).sqlString
                expect(sql1) == "(c1 = 1 OR (c1 = 1 AND c2 = 2))"
                
                let sql2 = (condition1 || condition1 && condition2).sqlString
                expect(sql2) == "(c1 = 1 OR (c1 = 1 AND c2 = 2))"
                
                let sql3 = ((condition1 || condition2) && (condition1 || condition2)).sqlString
                expect(sql3) == "((c1 = 1 OR c2 = 2) AND (c1 = 1 OR c2 = 2))"
            }
        }
    }
}














