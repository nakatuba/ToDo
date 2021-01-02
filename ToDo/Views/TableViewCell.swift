//
//  TableViewCell.swift
//  ToDo
//
//  Created by 中川翼 on 2020/03/14.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import M13Checkbox

class TableViewCell: UITableViewCell {

    let checkbox = M13Checkbox(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkbox.boxLineWidth = 2.0
        checkbox.checkmarkLineWidth = 4.0
        contentView.addSubview(checkbox)
        textLabel?.font = .systemFont(ofSize: 24)
    }

}
