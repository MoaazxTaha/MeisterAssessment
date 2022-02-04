//
//  CoreDataManager.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import UIKit
import CoreData

protocol CoreDataInterface {
    func retrieveTasks(searchParameters:SearchQuery?, completion:@escaping (([Task]) -> Void))
    func save(tasks: [Task])
}

class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    private override init() {}
    
}

extension CoreDataManager: CoreDataInterface {
    func retrieveTasks(searchParameters:SearchQuery? = nil, completion:@escaping (([Task]) -> Void)) {
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCD")
                request.returnsObjectsAsFaults = false
                var retrievedTasks: Set<Task> = []
                do {
                    let results = try context.fetch(request)
                    if !results.isEmpty {
                        for result in results as! [NSManagedObject] {
                            let task = Task()
                            task.id = result.value(forKey: "id") as? Int ?? 0
                            task.name = result.value(forKey: "name") as? String ?? ""
                            task.status = result.value(forKey: "status") as? Int  ?? 0
                            task.sectionId = result.value(forKey: "sectionId") as? Int ?? 0
                            task.projectName = result.value(forKey: "projectName") as? String ?? ""
                            retrievedTasks.insert(task)
                        }
                        let filteredResults = self.filter(tasks:Array(retrievedTasks), by: searchParameters)
                        completion(filteredResults)
                    } else {
                        completion([])
                    }
                } catch {
                    print("Error retrieving: \(error)")
                    completion([])
                }
                
            }
        }
        
    }
    
    func save(tasks: [Task]) {
        
        retrieveTasks() {[weak self] existedTasks in
            // saving allowed only in online mode.
            guard NetworkConnection.shared.isConnected else {
                return
            }
            
            let newTasksArray:Array<Task> = existedTasks + tasks
            let newtasks:Set<Task> = Set(newTasksArray.map { $0 })
            
            self?.deleteAllTasks()
            
            DispatchQueue.main.async {
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
                    
                    for task in newtasks {
                        let newTask = NSEntityDescription.insertNewObject(forEntityName: "TaskCD", into: context)
                        newTask.setValue(task.id, forKey: "id")
                        newTask.setValue(task.name, forKey: "name")
                        newTask.setValue(task.status, forKey: "status")
                        newTask.setValue(task.sectionId, forKey: "sectionId")
                        newTask.setValue(task.projectName, forKey: "projectName")
                    }
                    do {
                        try context.save()
                        print("Saved Successfully to internal DB")
                    } catch {
                        print("Error saving: \(error)")
                    }
                }
            }
        }
        
    }
    
    private func deleteAllTasks() {
        DispatchQueue.main.async {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCD")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                do
                {
                    try context.execute(deleteRequest)
                    try context.save()
                }
                catch
                {
                    print ("There was an error")
                }
            }
        }
    }
    
    private func filter(tasks:[Task], by searchParameters:SearchQuery?) -> [Task] {
        guard let searchParameters = searchParameters else {
            return tasks
        }

        guard !searchParameters.1.isEmpty else {
            return []
        }
        
        return tasks.filter({ task in
            if let name = task.name?.searchable(),
               let status = task.status {
                return name.contains(searchParameters.1.searchable()) && searchParameters.0.value.contains(status)
            } else {
                return false
            }
        })
    }
}
