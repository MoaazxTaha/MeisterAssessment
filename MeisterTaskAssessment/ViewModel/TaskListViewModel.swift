//
//  TaskListViewModel.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import Foundation

enum FilterationParameter: Int {
    case All,Active,Archived
    
    var value: [Int] {
        switch self {
        case .All:
            return [1,18]
        case .Active:
            return [1]
        case .Archived:
            return [18]
        }
    }
    
}

class TaskListViewModel {
    
    private var tasks:[Task] = []
    internal var filteredTasks:[Task]=[]
    
    private let repo = TaskListRepository()
    
    internal var searchingTerm: String = "" {
        didSet {
            filterResultsByKeyword()
        }
    }
    
    internal func fetchTasks(filterValue:FilterationParameter, handler:@escaping ()->Void) {
        
        repo.fetchTasks(filterValue: filterValue.value) { [weak self] tasks in
            guard let self = self else {return}
            
            if let tasks = tasks {
                self.tasks = tasks
                self.filterResultsByKeyword()
                handler ()
            } else {
                print("no data found ")
            }
        }
    }
    
    private func filterResultsByKeyword() {
        guard !searchingTerm.isEmpty else {
            filteredTasks = []
            return
        }
        
        let searchText = searchingTerm.searchable()
        self.filteredTasks = tasks.filter({ task in
            if let name = task.name?.searchable(),
               let projectName = task.projectName?.searchable() {
                return name.contains(searchText) || projectName.contains(searchText)
            } else {
                return false
            }
        })
        
        CoreDataManager.shared.save(tasks: filteredTasks)
    }
    
}

