//
//  User.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"

    @ID(key: .id) var id: UUID?
    @Field(key: "username") var username: String

    init() {}

    init(id: UUID? = nil, username: String) {
        self.id = id
        self.username = username
    }
}
