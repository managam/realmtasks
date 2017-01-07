//
//  TaskList.swift
//  RealmTasks
//
//  Created by Managam Silalahi on 1/7/17.
//  Copyright © 2017 Hossam Ghareeb. All rights reserved.
//

import Foundation
import RealmSwift

class TaskList: Object {
    dynamic var name = ""
    dynamic var createdAt = NSDate()
    let tasks = List<Task>()
}
