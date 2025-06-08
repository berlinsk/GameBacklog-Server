//
//  CreateUser.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on db: any Database) -> EventLoopFuture<Void> {
        db.schema("users")
            .id()
            .field("username", .string, .required)
            .field("passwordHash", .string, .required)
            .unique(on: "username")
            .create()
    }

    func revert(on db: any Database) -> EventLoopFuture<Void> {
        db.schema("users").delete()
    }
}
