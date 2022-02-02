//
//  String+Extensions.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import Foundation
extension String {
    func searchable() -> String {
        return self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
