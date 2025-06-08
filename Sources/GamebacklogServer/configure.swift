import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) async throws {
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateGame())
    app.migrations.add(CreateUserToken())
    app.migrations.add(AddGenresToGames())

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    try routes(app)
}
