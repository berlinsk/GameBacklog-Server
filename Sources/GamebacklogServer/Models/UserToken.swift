//
//  UserToken.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Fluent
import FluentKit
import Vapor

final class UserToken: Model, Content {
    static let schema = "tokens"

    @ID(key: .id) var id: UUID?
    @Field(key: "value") var value: String
    @Parent(key: "user_id") var user: User

    init() {}

    init(value: String, userID: User.IDValue) {
        self.value = value
        self.$user.id = userID
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    typealias User = GamebacklogServer.User
    var isValid: Bool { true }
}
