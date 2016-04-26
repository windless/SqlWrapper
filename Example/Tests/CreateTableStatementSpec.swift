//
//  CreateTableStatementSpec.swift
//  SqlWrapper
//
//  Created by 钟建明 on 16/4/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class CreateTableStatementSpec: QuickSpec {
    override func spec() {
        describe("CreateTableStatement") {
            it("creates table with integer column") {
                let statement = CreateTableStatement(tableName: "Student") { t in
                    t.id()
                    t.integer("age")
                    t.text("name")
                }
                expect(statement.sqlString) ==
                    "CREATE TABLE Student(ID INTEGER PRIMARY KEY AUTOINCREMENT, age INTEGER, name TEXT);"
            }
        }
    }
}

class AddTableColumnStatementSpec: QuickSpec {
    override func spec() {
        describe("AddTableColumnsStatement") {
            it("add one column to table") {
                let statement = AddTableColumnsStatement(tableName: "Student") { t in
                    t.text("name")
                }
                expect(statement.sqlString) ==
                    "ALTER TABLE Student ADD COLUMN name TEXT;"
            }
            
            it("add many columns to table") {
                let statement = AddTableColumnsStatement(tableName: "Student") { t in
                    t.text("name")
                    t.integer("age")
                }
                expect(statement.sqlString) ==
                    "ALTER TABLE Student ADD COLUMN name TEXT;\n" +
                    "ALTER TABLE Student ADD COLUMN age INTEGER;"
                
            }
        }
    }
}

class RenameTableStatementSpec: QuickSpec {
    override func spec() {
        describe("RenameTableStatement") {
            it("#sqlString") {
                let statement = RenameTableStatement(tableName: "Student", newTableName: "Teacher")
                expect(statement.sqlString) ==
                    "ALTER TABLE Student RENAME TO Teacher;"
            }
        }
    }
}

class DropTableStatementSpec: QuickSpec {
    override func spec() {
        describe("DropTableStatement") {
            it("#sqlString") {
                let statement = DropTableStatement(table: "Student")
                expect(statement.sqlString) ==
                    "DROP TABLE Student;"
            }
        }
    }
}

class AddIndexStatementSpec: QuickSpec {
    override func spec() {
        describe("AddIndexStatement") {
            it("#sqlString") {
                var statement = AddIndexStatement(table: "Student", columns: ["name"])
                expect(statement.sqlString) ==
                    "CREATE INDEX name_index ON Student (name);"
                
                statement = AddIndexStatement(table: "Student", columns: ["name", "age"])
                expect(statement.sqlString) ==
                    "CREATE INDEX name_age_index ON Student (name, age);"
            }
        }
    }
}














