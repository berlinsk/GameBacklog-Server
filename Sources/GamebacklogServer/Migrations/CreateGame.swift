//
//  CreateGame.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Fluent

struct CreateGame: Migration {
    func prepare(on db: any Database) -> EventLoopFuture<Void> {
        db.schema("games")
            .id()
            .field("title", .string, .required)
            .field("genres", .array(of: .string), .required)
            .field("platform", .string, .required)
            .field("cover_url", .string)
            .field("status", .string, .required)
            .field("rating", .int)
            .field("notes", .string)
            .field("owner_id", .uuid, .required, .references("users", "id"))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on db: any Database) -> EventLoopFuture<Void> {
        db.schema("games").delete()
    }
}
