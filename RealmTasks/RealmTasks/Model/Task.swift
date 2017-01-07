//
//  Task.swift
//  RealmTasks
//
//  Created by Managam Silalahi on 1/7/17.
//  Copyright © 2017 Hossam Ghareeb. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    dynamic var name = ""
    dynamic var createdAt = Date()
    dynamic var notes = ""
    dynamic var isCompleted = false
}
