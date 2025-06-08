//
//  AddGenresToGames.swift
//
//
//  Created by Берлинский Ярослав Владленович on 08.06.2025.
//

import Fluent

struct AddGenresToGames: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("games")
            .field("genres", .array(of: .string), .required, .sql(.default("[]")))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("games")
            .deleteField("genres")
            .update()
    }
}
