//
//  MainViewController.swift
//  ToDo
//
//  Created by 中川翼 on 2020/03/12.
//  Copyright © 2020 中川翼. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var checkButton: UIBarButtonItem!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.layer.shadowOpacity = 1.0
        addButton.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        addButton.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
        deleteButton.layer.shadowOpacity = 1.0
        deleteButton.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.tintColor = .white
        
        bannerView.adUnitID = "ca-app-pub-1193328696064480/1269633615"
        bannerView.rootViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
    }
    
    func loadBannerAd() {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    @IBAction func didTapCheckButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let checkAction = UIAlertAction(title: "全てチェック", style: .default, handler: { _ in
            let realm = try! Realm()
            try! realm.write {
                for todo in realm.objects(ToDo.self) {
                    todo.checked = true
                }
            }
            let tableVC = self.children[0] as! TableViewController
            tableVC.tableView.reloadData()
        })
        let uncheckAction = UIAlertAction(title: "全てのチェックを解除", style: .default, handler: { _ in
            let realm = try! Realm()
            try! realm.write {
                for todo in realm.objects(ToDo.self) {
                    todo.checked = false
                }
            }
            let tableVC = self.children[0] as! TableViewController
            tableVC.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(checkAction)
        alert.addAction(uncheckAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let tableVC = self.children[0] as! TableViewController
        tableVC.tableView.isEditing = editing
        addButton.isHidden = editing
        deleteButton.isHidden = editing
        checkButton.isEnabled = !editing
        for cell in tableVC.tableView.visibleCells as! [TableViewCell] {
            cell.checkbox.isHidden = editing
            if editing {
                cell.contentView.layoutMargins.left = 16
            } else {
                cell.contentView.layoutMargins.left = cell.checkbox.frame.width + 16
            }
        }
    }
    
    @IBAction func didTouchDownButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    @IBAction func didTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTouchUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        AccessoryView.shared.color = "White"
        let alert = UIAlertController(title: "ToDoの追加", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "追加", style: .default, handler: { _ in
            let textField = alert.textFields![0]
            guard let title = textField.text, !title.isEmpty else { return }
            let todo = ToDo()
            todo.title = title
            todo.color = AccessoryView.shared.color
            let realm = try! Realm()
            try! realm.write {
                realm.add(todo)
            }
            let tableVC = self.children[0] as! TableViewController
            tableVC.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: { textField in
            textField.returnKeyType = .done
            guard let whiteButtonColor = UIColor(named: "White") else { return }
            textField.inputAccessoryView = AccessoryView.shared.setAccessoryView(whiteButtonColor)
        })
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        let realm = try! Realm()
        let todoObjects = realm.objects(ToDo.self)
        let checkedToDoObjects = todoObjects.filter("checked == true")
        guard !checkedToDoObjects.isEmpty else { return }
        
        let alert = UIAlertController(title: "ToDoの削除", message: "\(checkedToDoObjects.count)つのToDoを削除してもいいですか？", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            try! realm.write {
                for _ in checkedToDoObjects {
                    guard let checkedToDo = todoObjects.filter("checked == true").first else { return }
                    guard let checkedIndex = todoObjects.index(of: checkedToDo) else { return }
                    guard let lastIndex = todoObjects.indices.last else { return }
                    for i in checkedIndex..<lastIndex {
                        todoObjects[i].title = todoObjects[i + 1].title
                        todoObjects[i].color = todoObjects[i + 1].color
                        todoObjects[i].checked = todoObjects[i + 1].checked
                    }
                    realm.delete(todoObjects[lastIndex])
                }
            }
            let tableVC = self.children[0] as! TableViewController
            tableVC.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

}
