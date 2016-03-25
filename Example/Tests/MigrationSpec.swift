//
//  MigrationSpec.swift
//  SqlWrapper
//
//  Created by 钟建明 on 16/3/25.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SqlWrapper

class MigrationSpec: QuickSpec {
    override func spec() {
        describe("Migration") {
            var migration: SQLMigration!
            beforeEach {
                migration = SQLMigration(version: 1)
            }
            
            context("creates table") {
                context("with integer column") {
                    
                    it("without any constraint") {
                        migration.createTable("People") { t in
                            t.integer("age")
                        }
                        
                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(age INT);"
                    }
                    
                    it("with not null constraint") {
                        migration.createTable("People") { t in
                            t.integer("age").notNull()
                        }
                        
                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(age INT NOT NULL);"
                    }
                    
                    it("id") {
                        migration.createTable("People") { t in
                            t.id()
                        }
                        
                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(ID INT PRIMARY KEY NOT NULL);"
                    }
                    
                    it("with default value") {
                        migration.createTable("People") { t in
                            t.integer("age").defaultValue(18)
                        }
                        
                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(age INT DEFAULT 18);"
                    }
                }
                
                it("creates table") {
                    migration.createTable("People") { t in
                        t.id()
                        t.integer("age").notNull()
                        t.text("name").unique()
                        t.real("height").defaultValue(181.2)
                        t.blob("image")
                    }
                    
                    expect(migration.buildScheme()) ==
                        "CREATE TABLE People(ID INT PRIMARY KEY NOT NULL, age INT NOT NULL, name TEXT UNIQUE, height REAL DEFAULT 181.2, image BLOB);"
                }
                
                it("adds index") {
                    migration.addIndex("People", column: "name")
                    migration.addIndex("People", indexName: "name_and_id", columns: "name", "ID")
                    expect(migration.buildScheme()) ==
                        "CREATE INDEX name ON People (name);\n" +
                        "CREATE INDEX name_and_id ON People (name, ID);"
                }
            }
        }
    }
}
