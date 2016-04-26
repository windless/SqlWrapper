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
                            "CREATE TABLE People(age INTEGER);"
                    }

                    it("with not null constraint") {
                        migration.createTable("People") { t in
                            t.integer("age").notNull()
                        }

                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(age INTEGER NOT NULL);"
                    }

                    it("id") {
                        migration.createTable("People") { t in
                            t.id()
                        }

                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(ID INTEGER PRIMARY KEY AUTOINCREMENT);"
                    }

                    it("with default value") {
                        migration.createTable("People") { t in
                            t.integer("age").defaultValue(18)
                        }

                        expect(migration.buildScheme()) ==
                            "CREATE TABLE People(age INTEGER DEFAULT 18);"
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
                        "CREATE TABLE People(ID INTEGER PRIMARY KEY AUTOINCREMENT, age INTEGER NOT NULL, name TEXT UNIQUE, height REAL DEFAULT 181.2, image BLOB);"
                }

                it("adds index") {
                    migration.addIndex("People", column: "name")
                    migration.addIndex("People", indexName: "name_and_id", columns: "name", "ID")
                    expect(migration.buildScheme()) ==
                        "CREATE INDEX name ON People (name);\n" +
                        "CREATE INDEX name_and_id ON People (name, ID);"
                }
            }

            context("Drop table") {
                it("drops table") {
                    migration.dropTable("People")
                    expect(migration.buildScheme()) ==
                        "DROP TABLE People;"
                }
            }

            context("Columns") {
                it("adds columns to table") {
                    migration.addColumnTo("People") { t in
                        t.integer("age").notNull()
                        t.text("name").unique()
                    }

                    expect(migration.buildScheme()) ==
                        "ALTER TABLE People ADD COLUMN age INTEGER NOT NULL;\n" +
                        "ALTER TABLE People ADD COLUMN name TEXT UNIQUE;"
                }
            }

            context("Raw sql") {
                it("build scheme with raw sql") {
                    migration.raw("ALERT TABLE People RENAME TO PeopleTemp")
                    migration.raw("ALTER TABLE PeopleTemp ADD COLUMN SEX char(1);")
                    expect(migration.buildScheme()) ==
                        "ALERT TABLE People RENAME TO PeopleTemp;\n" +
                        "ALTER TABLE PeopleTemp ADD COLUMN SEX char(1);"
                }
            }
        }
    }
}
