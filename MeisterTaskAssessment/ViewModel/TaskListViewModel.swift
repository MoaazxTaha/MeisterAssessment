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
    
    var query: NSPredicate {
        switch self {
        case .All:
            return NSCompoundPredicate(orPredicateWithSubpredicates: [FilterationParameter.Active.query, FilterationParameter.Archived.query])
        case .Archived, .Active:
            return NSPredicate(format: "status = %i", self.value.first!)
        }
    }
}

class TaskListViewModel {
    
    var tasksDidChange:(()->Void) = {}
    
    internal var filteredTasks:[Task]=[] {
        willSet {
            dataSource.filteredTasks = newValue
        }
    }
    
    private let repo = TaskListRepository()
    let dataSource = TableViewDataSource(filteredTasks: [])
    
    internal var filteringTerm: FilterationParameter = .All
    {
        didSet {
            fetchTasks(searchValues:(filteringTerm,searchingTerm))
        }
    }
    
    internal var searchingTerm: String = ""
    {
        didSet {
            fetchTasks(searchValues:(filteringTerm,searchingTerm))
        }
    }
    
    internal func fetchTasks(searchValues:SearchQuery) {
        repo.fetchTasks(searchValues: searchValues) { [weak self] tasks in
            guard let self = self else {return}
            self.filteredTasks = tasks
            self.tasksDidChange()
        }
    }
}

