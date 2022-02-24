//
//  Model.swift
//  Haarish ToDo Zuper
//
//  Created by Haarish on 24/02/22.
//

import UIKit

struct TodoList: Codable {
    let data: [Datum]?
    let totalRecords: Int?

    enum CodingKeys: String, CodingKey {
        case data
        case totalRecords = "total_records"
    }
}

// MARK: - Datum
struct Datum: Codable {
    let author: String?
    let id: Int?
    let isCompleted: Bool?
    let priority: Priority?
    let tag, title: String?

    enum CodingKeys: String, CodingKey {
        case author, id
        case isCompleted = "is_completed"
        case priority, tag, title
    }
}

enum Priority: String, Codable {
    case high = "HIGH"
    case low = "LOW"
    case medium = "MEDIUM"
}
