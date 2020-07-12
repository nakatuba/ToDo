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

    let accessoryView = UIView()
    let whiteButton = UIButton()
    let cyanButton = UIButton()
    let magentaButton = UIButton()
    let yellowButton = UIButton()
    var color = ""
    
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
        
        switch todoObjects[indexPath.row].color {
        case "White":
            cell.backgroundColor = .secondarySystemGroupedBackground
        default:
            cell.backgroundColor = UIColor(named: todoObjects[indexPath.row].color)
        }
        
        if todoObjects[indexPath.row].checked {
            cell.checkbox.checkState = .checked
            let attributeString =  NSMutableAttributedString(string: todoObjects[indexPath.row].title)
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
            cell.textLabel?.textColor = .systemGray
        } else {
            cell.checkbox.checkState = .unchecked
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = todoObjects[indexPath.row].title
            if cell.backgroundColor == UIColor.secondarySystemGroupedBackground {
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
        color = todoObjects[indexPath.row].color
        
        let alert = UIAlertController(title: "ToDoの編集", message: nil, preferredStyle: .alert)
        let changeAction = UIAlertAction(title: "変更", style: .default, handler: { _ in
            let textField = alert.textFields![0]
            guard let title = textField.text, !title.isEmpty else { return }
            try! realm.write {
                todoObjects[indexPath.row].title = title
                todoObjects[indexPath.row].color = self.color
            }
            tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: { textField in
            textField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
            textField.returnKeyType = .done
            
            self.accessoryView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
            self.accessoryView.backgroundColor = .systemGroupedBackground
            
            self.whiteButton.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
            self.whiteButton.backgroundColor = .secondarySystemGroupedBackground
            
            self.cyanButton.frame = CGRect(x: 60, y: 10, width: 40, height: 40)
            self.cyanButton.backgroundColor = UIColor(named: "Cyan")
            
            self.magentaButton.frame = CGRect(x: 110, y: 10, width: 40, height: 40)
            self.magentaButton.backgroundColor = UIColor(named: "Magenta")
            
            self.yellowButton.frame = CGRect(x: 160, y: 10, width: 40, height: 40)
            self.yellowButton.backgroundColor = UIColor(named: "Yellow")
            
            for button in [self.whiteButton, self.cyanButton, self.magentaButton, self.yellowButton] {
                button.layer.cornerRadius = button.frame.width / 2
                button.layer.borderWidth = 2.0
                button.addTarget(self, action: #selector(self.didTapColorButton(_:)), for: .touchUpInside)
                if button.backgroundColor == tableView.cellForRow(at: indexPath)?.backgroundColor {
                    button.layer.borderColor = UIColor.systemBlue.cgColor
                    button.setImage(.checkmark, for: .normal)
                } else {
                    button.layer.borderColor = UIColor.label.cgColor
                    button.setImage(nil, for: .normal)
                }
                self.accessoryView.addSubview(button)
            }
            textField.inputAccessoryView = self.accessoryView
        })
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func didTapColorButton(_ sender: UIButton) {
        switch sender {
        case whiteButton:
            color = "White"
            whiteButton.layer.borderColor = UIColor.systemBlue.cgColor
            whiteButton.setImage(.checkmark, for: .normal)
            for button in [cyanButton, magentaButton, yellowButton] {
                button.layer.borderColor = UIColor.label.cgColor
                button.setImage(nil, for: .normal)
            }
        case cyanButton:
            color = "Cyan"
            cyanButton.layer.borderColor = UIColor.systemBlue.cgColor
            cyanButton.setImage(.checkmark, for: .normal)
            for button in [whiteButton, magentaButton, yellowButton] {
                button.layer.borderColor = UIColor.label.cgColor
                button.setImage(nil, for: .normal)
            }
        case magentaButton:
            color = "Magenta"
            magentaButton.layer.borderColor = UIColor.systemBlue.cgColor
            magentaButton.setImage(.checkmark, for: .normal)
            for button in [whiteButton, cyanButton, yellowButton] {
                button.layer.borderColor = UIColor.label.cgColor
                button.setImage(nil, for: .normal)
            }
        case yellowButton:
            color = "Yellow"
            yellowButton.layer.borderColor = UIColor.systemBlue.cgColor
            yellowButton.setImage(.checkmark, for: .normal)
            for button in [whiteButton, cyanButton, magentaButton] {
                button.layer.borderColor = UIColor.label.cgColor
                button.setImage(nil, for: .normal)
            }
        default:
            break
        }
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
