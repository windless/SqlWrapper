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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

