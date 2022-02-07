//
//  TaskListRepository.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import Foundation

protocol RepositoryInterface {
    func fetchTasks(searchValues:SearchQuery, compilation: @escaping ([Task])->Void)
}

class TaskListRepository {
    
    //MARK: URL session
    
    private func APIRequest(searchValues:SearchQuery, compilation: @escaping ([Task])->Void) {
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: API.searchTask(searchValues).request) { [weak self] data, URLResponse, Error in
            guard let self = self else {return}
            
            if let Error = Error {
                print (Error.localizedDescription)
            }
            if let data = data {
                if let tasks = self.decodeJson(Data: data)?.tasks {
                    CoreDataManager.shared.save(tasks: tasks)
                    compilation(tasks)
                }
            }
        }
        task.resume()
    }
    
    //MARK: retrieve CoreData
    
    private func localRequest(searchValues:SearchQuery, compilation: @escaping ([Task])->Void){
        CoreDataManager.shared.retrieveTasks(with : searchValues) { tasks in
            compilation(tasks)
        }
    }
}

extension TaskListRepository:RepositoryInterface {
    func fetchTasks(searchValues:SearchQuery, compilation: @escaping ([Task])->Void) {
        
        if(NetworkConnection.shared.isConnected) {
            APIRequest(searchValues: searchValues) { tasks in
                compilation(tasks)
            }
        } else {
            localRequest(searchValues: searchValues) { tasks in
                compilation(tasks)
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

