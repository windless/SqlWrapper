//
//  ViewController.swift
//  SqlWrapper
//
//  Created by Abner Zhong on 03/23/2016.
//  Copyright (c) 2016 Abner Zhong. All rights reserved.
//

import UIKit
import SqlWrapper

class ViewController: UIViewController {
    var session: DatabaseSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory,
            .UserDomainMask, true)[0] as NSString
        let dbPath = libraryPath.stringByAppendingPathComponent("database.db")
        session = DatabaseSession(databasePath: dbPath)
        
        let migraion1 = SQLMigration(version: 1)
        migraion1.createTable("Student") { t in
            t.id()
            t.text("name").notNull()
            t.integer("age").notNull()
            t.real("grade").defaultValue(0)
        }
        
        let migraion2 = SQLMigration(version: 2)
        migraion2.createTable("Class") { t in
            t.id()
            t.text("name").notNull()
            t.integer("studentCount").defaultValue(0)
        }
        migraion2.addColumnTo("Student") { t in
            t.integer("classId")
        }
        
        let migration3 = SQLMigration(version: 3)
        migration3.addColumnTo("Student") { v in
            v.integer("sex").notNull().defaultValue(0)
            v.integer("height")
        }
        session.setup([migraion2, migraion1, migration3])
        
        let students = session.queryList(Student.self) { c in
            c("age") == 18
        }
        NSLog("students: \(students.count)")
        
        let student = session.querySingle(Student.self) { c in
            c("age") == 18 && c("name") == "9"
        }
        NSLog("\(student)")
        
        let count = session.queryCount(Student.self) { c in
            c("age") == 18
        }
        NSLog("age 18 count: \(count)")
        
        let all = session.queryAll(Student.self)
        NSLog("all \(all)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class Student: ActiveRecord {
    var name: String
    var age: Int
    var sex: Int
    var grade: Double?
    var classId: Int?
    var height: Int?
    
    init(name: String, age: Int, sex: Int) {
        self.name = name
        self.age = age
        self.sex = sex
        super.init()
    }
    
    required init() {
        name = ""
        age = 0
        sex = 0
    }
    
    override class var primaryKey: String? { return "ID" }
    
    override class func map<T: ActiveRecord>(resultSet: ResultSet) -> T? {
        let name = resultSet.string("name")!
        let age = resultSet.integer("age")!
        let sex = resultSet.integer("sex")!
        let grade = resultSet.double("grade")
        let classId = resultSet.integer("classId")
        let height = resultSet.integer("height")
        let id = resultSet.integer("ID")!
        
        let student = Student(name: name, age: age, sex: sex)
        student.ID = id
        student.grade = grade
        student.classId = classId
        student.height = height
        return student as? T
    }
}

