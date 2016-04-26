//
//  TableColumnSpec.swift
//  SqlWrapper
//
//  Created by 钟建明 on 16/4/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class TableColumnSpec: QuickSpec {
    override func spec() {
        describe("TableColumn") {
            it("#integer") {
                let c = TableColumn<Int>.integer("age")
                expect(c.sqlString) ==
                    "age INTEGER"
            }
            
            it("#text") {
                let c = TableColumn<String>.text("name")
                expect(c.sqlString) ==
                    "name TEXT"
            }
            
            it("#real") {
                let c = TableColumn<Double>.real("weight")
                expect(c.sqlString) ==
                    "weight REAL"
            }
            
            it("#blob") {
                let c = TableColumn<NSData>.blob("image")
                expect(c.sqlString) ==
                    "image BLOB"
            }
            
            context("with constrains") {
                it("#primaryKey") {
                    let c = TableColumn<Int>.integer("id").primaryKey()
                    expect(c.sqlString) ==
                        "id INTEGER PRIMARY KEY"
                }
                
                it("#defaultValue") {
                    let c = TableColumn<String>.text("name").defaultValue("no name")
                    expect(c.sqlString) ==
                        "name TEXT DEFAULT 'no name'"
                }
                
                it("#notNull") {
                    let c = TableColumn<String>.text("name").notNull()
                    expect(c.sqlString) ==
                        "name TEXT NOT NULL"
                }
                
                it("#unique") {
                    let c = TableColumn<String>.text("name").unique()
                    expect(c.sqlString) ==
                        "name TEXT UNIQUE"
                }
                
                it("#autoIncrement") {
                    let c = TableColumn<Int>.integer("id").autoIncrement()
                    expect(c.sqlString) ==
                        "id INTEGER AUTOINCREMENT"
                }
            }
        }
    }
}






























