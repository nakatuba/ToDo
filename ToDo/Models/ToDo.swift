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

class AccessoryView {
    private init() {}
    static let shared = AccessoryView()
    var color = ""
    
    let whiteButton: UIButton = {
        let whiteButton = UIButton()
        whiteButton.backgroundColor = UIColor(named: "White")
        return whiteButton
    }()
    
    let cyanButton: UIButton = {
        let cyanButton = UIButton()
        cyanButton.backgroundColor = UIColor(named: "Cyan")
        return cyanButton
    }()
    
    let magentaButton: UIButton = {
        let magentaButton = UIButton()
        magentaButton.backgroundColor = UIColor(named: "Magenta")
        return magentaButton
    }()
    
    let yellowButton: UIButton = {
        let yellowButton = UIButton()
        yellowButton.backgroundColor = UIColor(named: "Yellow")
        return yellowButton
    }()
    
    func setAccessoryView(_ selectedButtonColor: UIColor) -> UIView {
        let accessoryView = UIView()
        accessoryView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
        accessoryView.backgroundColor = .systemGroupedBackground
        
        for (i, button) in [whiteButton, cyanButton, magentaButton, yellowButton].enumerated() {
            button.frame = CGRect(x: 50 * i + 10, y: 10, width: 40, height: 40)
            button.addTarget(self, action: #selector(didTapColorButton(_:)), for: .touchUpInside)
            button.layer.cornerRadius = button.frame.width / 2
            button.layer.borderWidth = 2.0
            if button.backgroundColor == selectedButtonColor {
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.setImage(.checkmark, for: .normal)
            } else {
                button.layer.borderColor = UIColor.label.cgColor
                button.setImage(nil, for: .normal)
            }
            accessoryView.addSubview(button)
        }
        
        return accessoryView
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
    
}
