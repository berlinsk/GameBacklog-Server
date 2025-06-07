import Fluent
import Vapor

import Vapor

func routes(_ app: Application) throws {
    let user = UserController()
    let game = GameController()

    app.post("login", use: user.login)

    let tokenProtected = app.grouped(UserToken.authenticator(), User.guardMiddleware())
    let games = tokenProtected.grouped("games")

    games.get(use: game.all)
    games.post(use: game.create)
    games.group(":id") { g in
        g.get(use: game.byID)
        g.patch(use: game.update)
        g.delete(use: game.delete)
    }
}
