//
//  UserController.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Vapor
import Fluent

struct UserController {
    func login(req: Request) async throws -> UserTokenResponse {
        let data = try req.content.decode(LoginRequest.self)

        if let user = try await User.query(on: req.db)
            .filter(\.$username == data.username)
            .first() {
            return try await token(for: user, req: req)
        } else {
            let user = User(username: data.username)
            try await user.save(on: req.db)
            return try await token(for: user, req: req)
        }
    }

    private func token(for user: User, req: Request) async throws -> UserTokenResponse {
        let value = [UInt8].random(count: 16).base64
        let token = UserToken(value: value, userID: try user.requireID())
        try await token.save(on: req.db)
        return UserTokenResponse(username: user.username, token: value)
    }
}

struct LoginRequest: Content {
    var username: String
}

struct UserTokenResponse: Content {
    var username: String
    var token: String
}
