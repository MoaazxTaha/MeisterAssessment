//
//  TaskListRepository.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import Foundation

class Result:Codable {
    let results:Results?
}

class Results:Codable {
    let tasks:[Task]?
    let sections:[Section]?
    let projects:[Project]?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tasks = try container.decode([Task].self, forKey:.tasks)
        sections = try container.decode([Section].self, forKey: .sections)
        projects = try container.decode([Project].self, forKey: .projects)

        tasks?.forEach({ Task in
            if let parentSection = sections?.first(where: {$0.id == Task.sectionId})
                ,let parentProject = projects?.first(where: {$0.id == parentSection.projectId}) {
            Task.projectName = parentProject.name
            }
        })
    }
}


class Task:Codable {
    var id:Int?
    var name:String?
    var status:Int?
    var sectionId:Int?
    var projectName:String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, projectName
        case sectionId = "section_id"
    }
    
}

class Section:Codable {
    let id:Int?
    let projectId:Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
    }
}

class Project:Codable {
    let id:Int?
    let name:String?
}
