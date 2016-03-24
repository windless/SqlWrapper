//
//  SQLValueTransformerSpec.swift
//  SqlWrapper
//
//  Created by A.Z on 16/3/23.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class SQLValueTransformerSpec: QuickSpec {
    override func spec() {
        describe("SQLValueTransformer") {
            it("tranform Int right") {
                let int: Int = 1
                expect(SQLValueTransformer.transform(int)) == "1"
            }
            
            it("transform Double right") {
                let double: Double = 1.0
                expect(SQLValueTransformer.transform(double)) == "1.0"
            }
            
            it("transform Float right") {
                let float: Float = 1.0
                expect(SQLValueTransformer.transform(float)) == "1.0"
            }
            
            it("transform String right") {
                expect(SQLValueTransformer.transform("hello")) == "'hello'"
                expect(SQLValueTransformer.transform("hello, 'world'")) == "'hello, ''world'''"
            }
            
            it("transform NSDate right") {
                let date = NSDate()
                expect(SQLValueTransformer.transform(date)) == "\(Int(date.timeIntervalSince1970 * 1000))"
            }
            
            it("transform SQLValue right") {
                let value = SQLValueMock()
                expect(SQLValueTransformer.transform(value)) == value.toSqlValue()
            }
            
            it("transform nil right") {
                let value: Any? = nil
                expect(SQLValueTransformer.transform(value)) == "null"
            }
        }
    }
    
    class SQLValueMock: SQLValue {
        func toSqlValue() -> String {
            return "mock"
        }
    }
}
