//
//  CreateGameRequest.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Vapor

struct CreateGameRequest: Content {
    var title: String
    var platform: String
    var coverURL: String?
    var status: GameStatus
    var rating: Int?
    var notes: String?
}
