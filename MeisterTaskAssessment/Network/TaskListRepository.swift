//
//  TaskListRepository.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import Foundation


class TaskListRepository {
    
    func fetchTasks(filterValue:[Int], compilation: @escaping ([Task]?)->Void) {
        if(NetworkConnection.shared.isConnected) {
            APIRequest(filterValue: filterValue) { tasks in
                compilation(tasks)
            }
        } else {
            localRequest(filterValue: filterValue) { tasks in
                compilation(tasks)
            }
        }
    }
    
    private func APIRequest(filterValue:[Int], compilation: @escaping ([Task]?)->Void) {
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: API.searchTask(filterValue).request) { [weak self] data, URLResponse, Error in
            guard let self = self else {return}
            
            if let Error = Error {
                print (Error.localizedDescription)
            }
            if let data = data {
                let tasks = self.decodeJson(Data: data)?.tasks
//                please uncomment nextline in case it's intended to save the Results from the API before applying search.
//                CoreDataManager.shared.save(tasks: tasks)
                compilation(tasks)
            }
        }
        task.resume()
    }
    
    private func localRequest(filterValue:[Int], compilation: @escaping ([Task]?)->Void){
        CoreDataManager.shared.retrieveTasks { tasks in
            if let tasks = tasks {
                let filteredTasks = tasks.filter({filterValue.contains($0.status ?? 1)})
                compilation(filteredTasks)
            } else {
                compilation(nil)
            }
        }
    }
}



//MARK: - decoding jason data from api

extension TaskListRepository {
    
    private func decodeJson(Data:Data)-> Results? {
        
        let decoder = JSONDecoder()
        
        do {
            let dataDecoded = try decoder.decode(Result.self, from: Data)
            return dataDecoded.results
            
        } catch let error {
            print(String(describing: error))
            return nil
        }
    }
}

