//
//  GameController.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Vapor
import Fluent

struct GameController {
    func all(req: Request) async throws -> [Game] {
        let user = try req.auth.require(User.self)
        return try await Game.query(on: req.db)
            .filter(\.$owner.$id == user.requireID())
            .all()
    }

    func byID(req: Request) async throws -> Game {
        let user = try req.auth.require(User.self)
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let game = try await Game.find(id, on: req.db),
              game.$owner.id == user.id else {
            throw Abort(.notFound)
        }
        return game
    }

    func create(req: Request) async throws -> Game {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(CreateGameRequest.self)

        let game = Game(
            title: input.title,
            platform: input.platform,
            coverURL: input.coverURL,
            status: input.status,
            rating: input.rating,
            notes: input.notes,
            ownerID: try user.requireID()
        )

        try await game.save(on: req.db)
        return game
    }

    func update(req: Request) async throws -> Game {
        let user = try req.auth.require(User.self)
        guard let id = req.parameters.get("id", as: UUID.self),
              let existing = try await Game.find(id, on: req.db),
              existing.$owner.id == user.id else {
            throw Abort(.notFound)
        }

        let incoming = try req.content.decode(Game.self)
        existing.title = incoming.title
        existing.platform = incoming.platform
        existing.coverURL = incoming.coverURL
        existing.status = incoming.status
        existing.rating = incoming.rating
        existing.notes = incoming.notes
        try await existing.save(on: req.db)
        return existing
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        guard let id = req.parameters.get("id", as: UUID.self),
              let game = try await Game.find(id, on: req.db),
              game.$owner.id == user.id else {
            throw Abort(.notFound)
        }
        try await game.delete(on: req.db)
        return .noContent
    }
}
