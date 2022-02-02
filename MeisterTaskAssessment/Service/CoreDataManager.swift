//
//  CoreDataManager.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    private override init() {}
    
    func retrieveTasks(completion:@escaping (([Task]?) -> Void)) {
        
        DispatchQueue.main.async {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskCD")
                request.returnsObjectsAsFaults = false
                var retrievedTasks: [Task] = []
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
                            retrievedTasks.append(task)
                        }
                        completion(retrievedTasks)
                    } else {
                        completion([])
                    }
                } catch {
                    print("Error retrieving: \(error)")
                    completion(nil)
                }
                
            }
        }
    }
    
    func save(tasks: [Task]) {
        // saving allowed only in online mode.
        guard NetworkConnection.shared.isConnected else {
            return
        }
        
        // clear table before insert new records(if exist).
        guard !tasks.isEmpty else {return}
        deleteAllTasks()
        
        DispatchQueue.main.async {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
                
                for task in tasks {
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
}
