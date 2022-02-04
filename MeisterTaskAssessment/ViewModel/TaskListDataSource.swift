//
//  TaskListDataSource.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 03/02/2022.
//

import UIKit

class TableViewDataSource:NSObject, UITableViewDataSource {
    
    var filteredTasks:[Task] = []
    
    private var listIsEmpty:Bool {
        return filteredTasks.isEmpty
    }
    
    init(filteredTasks: [Task]) {
        super.init()
        self.filteredTasks = filteredTasks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !listIsEmpty else {return 1}
        
        return (filteredTasks.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !listIsEmpty else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptySearchBarCell.cellIdentifier, for: indexPath) as! EmptySearchBarCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.cellIdentifier, for: indexPath) as! TaskCell
        cell.configureCell(with: filteredTasks[indexPath.row])
        return cell
    }
}
