//
//  CoreDataManager.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import UIKit
import CoreData

protocol CoreDataInterface {
    func retrieveTasks(with query:SearchQuery?, completion:@escaping (([Task]) -> Void))
    func save(tasks: [Task])
}

class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    private override init() {}
    
}

extension CoreDataManager: CoreDataInterface {
    func retrieveTasks(with query:SearchQuery? = nil, completion:@escaping (([Task]) -> Void)) {
        DispatchQueue.main.async {
            if let application = (UIApplication.shared.delegate as? AppDelegate) {
                let context = application.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCD")
                
                if let query = query {
                    guard !query.1.isEmpty else {
                        completion([])
                        return
                    }
                    
                    let namePredicate = NSPredicate(format: "name CONTAINS[c] %@",query.1)
                    let statusPredicate = query.0.query
                    
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate,statusPredicate])
                    
                }
                request.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(request)
                    if !results.isEmpty {
                        var retrievedTasks:[Task] = []
                        for result in results as! [NSManagedObject] {
                            let task = Task()
                            task.id = result.value(forKey: "id") as? Int ?? 0
                            task.name = result.value(forKey: "name") as? String ?? ""
                            task.status = result.value(forKey: "status") as? Int  ?? 0
                            task.sectionId = result.value(forKey: "sectionId") as? Int ?? 0
                            task.projectName = result.value(forKey: "projectName") as? String ?? ""
                            task.updated_at = result.value(forKey: "updated_at") as? String ?? ""
                            retrievedTasks.append(task)
                        }
                        completion(retrievedTasks)
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
        // saving allowed only in online mode.
        guard NetworkConnection.shared.isConnected else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let application = (UIApplication.shared.delegate as? AppDelegate) {
                let context = application.persistentContainer.viewContext
                
                for task in tasks {
                    if let existedTask = self.retriveTask(into: context, id: task.id ?? 0).first {
                        self.compare(existedTask: existedTask, with: task)
                    } else { //add new task if not exist
                        let newTask = NSEntityDescription.insertNewObject(forEntityName: "TaskCD", into: context)
                        newTask.setValue(task.id, forKey: "id")
                        newTask.setValue(task.name, forKey: "name")
                        newTask.setValue(task.status, forKey: "status")
                        newTask.setValue(task.sectionId, forKey: "sectionId")
                        newTask.setValue(task.projectName, forKey: "projectName")
                        newTask.setValue(task.updated_at, forKey: "updated_at")
                    }
                    
                    
                }
                application.saveContext()
            }
        }
    }
    
    private func compare(existedTask:NSManagedObject ,with newTask:Task) {
        let existedVersionupdated_at = existedTask.value(forKey: "updated_at") as? String ?? ""
        if let existedDate = existedVersionupdated_at.toDate(),
           let newDate = newTask.updated_at?.toDate(),
           existedDate.compare(newDate) == .orderedAscending
        { //update in case there is update to fetched tasks.
            existedTask.setValue(newTask.name, forKey: "name")
            existedTask.setValue(newTask.status, forKey: "status")
            existedTask.setValue(newTask.sectionId, forKey: "sectionId")
            existedTask.setValue(newTask.projectName, forKey: "projectName")
            existedTask.setValue(newTask.updated_at, forKey: "updated_at")
        }
    }
    
    private func retriveTask(into context:NSManagedObjectContext, id: Int) -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCD")
        request.predicate = NSPredicate(format: "id == %i",id)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            return result as! [NSManagedObject]
        } catch {
            print("Error retrieving: \(error)")
            return []
        }
    }
    
    private func deleteAllTasks() {
        DispatchQueue.main.async {
            if let application = (UIApplication.shared.delegate as? AppDelegate) {
                let context = application.persistentContainer.viewContext
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCD")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                
                do {
                    try context.execute(deleteRequest)
                } catch let error {
                    print ("an error occured while deletion:\(error)")
                }
                application.saveContext()
            }
        }
    }
    
    //    used NSPredicate instead
    //    private func filter(tasks:[Task], by searchParameters:SearchQuery?) -> [Task] {
    //        guard let searchParameters = searchParameters else {
    //            return tasks
    //        }
    //
    //        guard !searchParameters.1.isEmpty else {
    //            return []
    //        }
    //
    //        return tasks.filter({ task in
    //            if let name = task.name?.searchable(),
    //               let status = task.status {
    //                return name.contains(searchParameters.1.searchable()) && searchParameters.0.value.contains(status)
    //            } else {
    //                return false
    //            }
    //        })
    //    }
    
}
