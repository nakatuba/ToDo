//
//  TableViewController.swift
//  ToDo
//
//  Created by 中川翼 on 2020/03/13.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift
import M13Checkbox

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 56
        tableView.tableFooterView?.frame.size.height = 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let todoObjects = realm.objects(ToDo.self)
        
        return todoObjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let realm = try! Realm()
        let todoObjects = realm.objects(ToDo.self)
        cell.backgroundColor = UIColor(named: todoObjects[indexPath.row].color)
        
        if todoObjects[indexPath.row].checked {
            cell.checkbox.checkState = .checked
            let attributedString = NSAttributedString(string: todoObjects[indexPath.row].title,
                                                      attributes: [.strikethroughStyle: NSUnderlineStyle.thick.rawValue])
            cell.textLabel?.attributedText = attributedString
            cell.textLabel?.textColor = .systemGray
        } else {
            cell.checkbox.checkState = .unchecked
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = todoObjects[indexPath.row].title
            if cell.backgroundColor == UIColor(named: "White") {
                cell.textLabel?.textColor = .label
            } else {
                cell.textLabel?.textColor = .black
            }
        }
        
        cell.checkbox.addTarget(self, action: #selector(checked(_:)), for: .valueChanged)
        cell.checkbox.isHidden = false
        cell.contentView.layoutMargins.left = cell.checkbox.frame.width + 16
        
        return cell
    }
    
    @objc func checked(_ sender: M13Checkbox) {
        let realm = try! Realm()
        let todoObjects = realm.objects(ToDo.self)
        let point = tableView.convert(CGPoint.zero, from: sender)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        switch sender.checkState {
        case .checked:
            try! realm.write {
                todoObjects[indexPath.row].checked = true
            }
        case .unchecked:
            try! realm.write {
                todoObjects[indexPath.row].checked = false
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        let todoObjects = realm.objects(ToDo.self)
        AccessoryView.shared.color = todoObjects[indexPath.row].color
        
        let alert = UIAlertController(title: "ToDoの編集", message: nil, preferredStyle: .alert)
        let changeAction = UIAlertAction(title: "変更", style: .default, handler: { _ in
            let textField = alert.textFields![0]
            guard let title = textField.text, !title.isEmpty else { return }
            try! realm.write {
                todoObjects[indexPath.row].title = title
                todoObjects[indexPath.row].color = AccessoryView.shared.color
            }
            tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: { textField in
            textField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
            textField.returnKeyType = .done
            guard let selectedButtonColor = UIColor(named: todoObjects[indexPath.row].color) else { return }
            textField.inputAccessoryView = AccessoryView.shared.setAccessoryView(selectedButtonColor)
        })
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            let todoObjects = realm.objects(ToDo.self)
            guard let lastIndex = todoObjects.indices.last else { return }
            try! realm.write {
                for i in indexPath.row..<lastIndex {
                    todoObjects[i].title = todoObjects[i + 1].title
                    todoObjects[i].color = todoObjects[i + 1].color
                    todoObjects[i].checked = todoObjects[i + 1].checked
                }
                realm.delete(todoObjects[lastIndex])
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let realm = try! Realm()
        let todoObjects = realm.objects(ToDo.self)
        let sourceTitle = todoObjects[sourceIndexPath.row].title
        let sourceColor = todoObjects[sourceIndexPath.row].color
        let sourceChecked = todoObjects[sourceIndexPath.row].checked
        try! realm.write {
            if sourceIndexPath.row < destinationIndexPath.row {
                for i in sourceIndexPath.row..<destinationIndexPath.row {
                    todoObjects[i].title = todoObjects[i + 1].title
                    todoObjects[i].color = todoObjects[i + 1].color
                    todoObjects[i].checked = todoObjects[i + 1].checked
                }
            } else if destinationIndexPath.row < sourceIndexPath.row {
                for i in (destinationIndexPath.row + 1...sourceIndexPath.row).reversed() {
                    todoObjects[i].title = todoObjects[i - 1].title
                    todoObjects[i].color = todoObjects[i - 1].color
                    todoObjects[i].checked = todoObjects[i - 1].checked
                }
            }
            todoObjects[destinationIndexPath.row].title = sourceTitle
            todoObjects[destinationIndexPath.row].color = sourceColor
            todoObjects[destinationIndexPath.row].checked = sourceChecked
        }
    }

}
