//
//  Game.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Fluent
import Vapor

enum GameStatus: String, Codable {
    case completed
    case playing
    case backlog
    case abandoned
}

final class Game: Model, Content {
    static let schema = "games"

    @ID(key: .id) var id: UUID?
    @Field(key: "title") var title: String
    @Field(key: "platform") var platform: String
    @Field(key: "cover_url") var coverURL: String?
    @Enum(key: "status") var status: GameStatus
    @Field(key: "rating") var rating: Int?
    @Field(key: "notes") var notes: String?
    @Parent(key: "owner_id") var owner: User
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}

    init(id: UUID? = nil,
         title: String,
         platform: String,
         coverURL: String?,
         status: GameStatus,
         rating: Int?,
         notes: String?,
         ownerID: User.IDValue) {
        self.id = id
        self.title = title
        self.platform = platform
        self.coverURL = coverURL
        self.status = status
        self.rating = rating
        self.notes = notes
        self.$owner.id = ownerID
    }
}
