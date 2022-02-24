//
//  TodoCell.swift
//  Haarish ToDo Zuper
//
//  Created by Haarish on 24/02/22.
//

import UIKit

class TodoCell: UICollectionViewCell {
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 10
            borderView.layer.borderWidth = 1
            borderView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var tickCircle: UIView! {
        didSet {
            tickCircle.layer.borderWidth = 1
            tickCircle.layer.borderColor = UIColor.systemGray4.cgColor
            tickCircle.layer.cornerRadius = tickCircle.frame.height / 2
            tickCircle.layer.shouldRasterize = true
        }
    }
    @IBOutlet weak var tagLabel: UILabel! {
        didSet {
            tagLabel.layer.cornerRadius = 1
            tagLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var priorityCircle: UIView! {
        didSet {
            priorityCircle.layer.cornerRadius = priorityCircle.frame.height / 2
            priorityCircle.layer.shouldRasterize = true
        }
    }
    let identifier = "TodoCell"
    
    func setData(priority: String?, todo: String?, tag: String?, isCompleted: Bool?) {
        contentLabel.text = todo ?? ""
        tagLabel.text = tag ?? ""
        
        if isCompleted == false || isCompleted == nil {
            tickCircle.backgroundColor = UIColor.clear
            tickImage.isHidden = true
        }
        else {
            tickCircle.backgroundColor = UIColor.systemIndigo
            tickImage.isHidden = false
        }
        
        switch(priority) {
        case "LOW":
            priorityCircle.backgroundColor = UIColor.green
        
        case "MEDIUM":
            priorityCircle.backgroundColor = UIColor.orange
            
        case "HIGH":
            priorityCircle.backgroundColor = UIColor.red
            
        default:
            priorityCircle.backgroundColor = UIColor.clear
        }
    }
}

