//
//  GameController.swift
//
//
//  Created by Берлинский Ярослав Владленович on 07.06.2025.
//

import Vapor
import Fluent

struct GameListResponse: Content {
    let total: Int
    let games: [Game]
}

struct GameController {
    func all(req: Request) async throws -> GameListResponse {
        let user = try req.auth.require(User.self)
        var query = try Game.query(on: req.db)
            .filter(\.$owner.$id == user.requireID())

        // status filter
        if let statusRaw = req.query[String.self, at: "status"],
           let status = GameStatus(rawValue: statusRaw) {
            query = query.filter(\.$status == status)
        }

        // platform filter
        if let platform = req.query[String.self, at: "platform"] {
            query = query.filter(\.$platform == platform)
        }
        
        // min rating filter
        if let minRating = req.query[Int.self, at: "minRating"] {
            query = query.filter(\.$rating >= minRating)
        }
        
        // max rating filter
        if let maxRating = req.query[Int.self, at: "maxRating"] {
            query = query.filter(\.$rating <= maxRating)
        }

        // find by name(register's not matter)
        if let search = req.query[String.self, at: "search"] {
            query = query.group(.or) { or in
                or.filter(\.$title ~~ search)
            }
        }

        // sort
        let sortBy = req.query[String.self, at: "sortBy"] ?? "createdAt"
        let order = req.query[String.self, at: "order"] ?? "desc"

        switch sortBy {
        case "title":
            query = query.sort(\.$title, order == "desc" ? .descending : .ascending)
        case "platform":
            query = query.sort(\.$platform, order == "desc" ? .descending : .ascending)
        case "rating":
            query = query.sort(\.$rating, order == "desc" ? .descending : .ascending)
        default:
            query = query.sort(\.$createdAt, order == "desc" ? .descending : .ascending)
        }
        
        // genres filter
        var games = try await query.all()
        let genres = req.query[[String].self, at: "genre"]?.map { $0.lowercased() } ?? []
        if !genres.isEmpty {
            games = games.filter { game in
                let lowercasedGenres = Set(game.genres.map { $0.lowercased() })
                return genres.allSatisfy { lowercasedGenres.contains($0) }
            }
        }
        
        // general pagination number
        let total = games.count

        // pagination
        let limit = req.query[Int.self, at: "limit"] ?? 50
        let offset = req.query[Int.self, at: "offset"] ?? 0
        let paginated = Array(games.dropFirst(offset).prefix(limit))

        return GameListResponse(total: total, games: games)
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
            genres: input.genres,
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
              existing.$owner.id == (try user.requireID()) else {
            throw Abort(.notFound)
        }

        let incoming = try req.content.decode(UpdateGameRequest.self)
        existing.title = incoming.title
        existing.genres = incoming.genres
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
