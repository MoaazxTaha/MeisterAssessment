//
//  EmptySearchBarCell.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import UIKit

class EmptySearchBarCell: UITableViewCell {

    @IBOutlet weak var searchMessage: UILabel!
    static let cellIdentifier = "EmptySearchBarCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        searchMessage.text = "search for a Task \n with a few keywords"
    }
}
