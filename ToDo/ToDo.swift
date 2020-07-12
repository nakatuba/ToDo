//
//  ToDo.swift
//  ToDo
//
//  Created by 中川翼 on 2020/03/16.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift

class ToDo: Object {
    @objc dynamic var title = ""
    @objc dynamic var color = ""
    @objc dynamic var checked = false
}
