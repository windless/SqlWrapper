//
//  ActiveRecordSpec.swift
//  SqlWrapper
//
//  Created by 钟建明 on 16/3/25.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class ActiveRecordSpec: QuickSpec {
    override func spec() {
        describe("ActiveRecord") {
            var activeRecord: ActiveRecord!
            
            beforeEach {
                activeRecord = MockActiveRecord()
            }
            
            it("has primary key") {
                expect(activeRecord!.dynamicType.primaryKey) == "primaryKey"
            }
            
            it("has ignore properties") {
                expect(activeRecord!.dynamicType.ignoreProperties) == ["ignoredProperty"]
            }
            
            it("has table name") {
                expect(activeRecord!.dynamicType.table) == "MockActiveRecord"
            }
            
            it("lists properties without ignored properties") {
                let properties: [(String, Any)] = activeRecord.properties
                expect(properties.map { $0.0 }) == ["primaryKey", "varString", "varStringOption", "varStringOptionNil", "letString", "letInt"]
            }
            
            it("builds insert sql") {
                let statement = ActiveRecordInsertStatement(activeRecord: activeRecord)
                expect(statement.sqlString) ==
                    "INSERT INTO MockActiveRecord (\"primaryKey\", \"varString\", \"varStringOption\", \"varStringOptionNil\", \"letString\", \"letInt\") VALUES ('primaryKey', 'varString', 'varStringOption', null, 'letString', 1);"
            }
            
            it("builds update sql") {
                let statement = ActiveRecordUpdateStatement(activeRecord: activeRecord)
                expect(statement.sqlString) ==
                    "UPDATE MockActiveRecord SET \"varString\" = 'varString', \"varStringOption\" = 'varStringOption', \"varStringOptionNil\" = null, \"letString\" = 'letString', \"letInt\" = 1 WHERE \"primaryKey\" = 'primaryKey';"
            }
            
            it("build delete sql") {
                let statement = ActiveRecordDeleteStatement(activeRecord: activeRecord)
                expect(statement.sqlString) ==
                    "DELETE FROM MockActiveRecord WHERE \"primaryKey\" = 'primaryKey';"
            }
            
            it("has primaryKeyValue") {
                expect(activeRecord.primaryKeyValue as? String) == "primaryKey"
            }
        }
    }
}

class MockActiveRecord: ActiveRecord {
    override class var primaryKey: String {
        return "primaryKey"
    }
    
    override class var ignoreProperties: [String] {
        return ["ignoredProperty"]
    }
    
    var primaryKey: String = "primaryKey"
    
    var varString: String = "varString"
    var varStringOption: String? = "varStringOption"
    var varStringOptionNil: String? = nil
    let letString: String = "letString"
    
    let letInt: Int = 1
    
    var ignoredProperty: Int?
}

















