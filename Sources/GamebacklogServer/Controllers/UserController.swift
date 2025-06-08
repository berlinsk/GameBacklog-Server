//
//  UserController.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Vapor
import Fluent

struct UserTokenResponse: Content {
    let username: String
    let token: String
}

struct LoginRequest: Content {
    let username: String
    let password: String
}

struct UserController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        routes.post("login", use: login)
        routes.grouped(UserToken.authenticator(), User.guardMiddleware())
              .delete("logout", use: logout)
    }

    func login(req: Request) async throws -> UserTokenResponse {
        let payload = try req.content.decode(LoginRequest.self)

        // find user
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$username == payload.username)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Wrong credentials")
        }

        // password
        // create/save token
        let rawToken = [UInt8].random(count: 32).base64
        let token = UserToken(value: rawToken, userID: try user.requireID())
        try await token.save(on: req.db)

        return UserTokenResponse(username: user.username, token: rawToken)
    }

    func logout(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        try await UserToken.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .delete()
        return .noContent
    }
}
