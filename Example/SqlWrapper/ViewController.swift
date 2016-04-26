//
//  ViewController.swift
//  SqlWrapper
//
//  Created by Abner Zhong on 03/23/2016.
//  Copyright (c) 2016 Abner Zhong. All rights reserved.
//

import UIKit
import SqlWrapper
import FMDB

class ViewController: UIViewController {
    var session: FMDatabaseQueue!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory,
            .UserDomainMask, true)[0] as NSString
        let dbPath = libraryPath.stringByAppendingPathComponent("database.db")
        session = FMDatabaseQueue(path: dbPath)
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
    
    override class var primaryKey: String { return "ID" }
    
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

