//
//  TableViewCell.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import UIKit

class TaskCell: UITableViewCell {
    
    static let cellIdentfier = "TaskCell"
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var containView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func configureCell(with task:Task) {
        containView.layer.cornerRadius = 10
        containView.layer.borderColor = UIColor.lightGray.cgColor
        containView.layer.borderWidth = 1
        projectName.text = task.projectName
        taskName.text = task.name
    }
    
}
