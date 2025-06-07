//
//  UpdateGameRequest.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//
import Vapor

struct UpdateGameRequest: Content {
    let title: String
    let platform: String
    let coverURL: String?
    let status: GameStatus
    let rating: Int?
    let notes: String?
}
