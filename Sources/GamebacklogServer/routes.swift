import Fluent
import Vapor

import Vapor

func routes(_ app: Application) throws {
    let user = UserController()
    app.post("register", use: user.register)
    app.post("login", use: user.login)
    app.grouped(UserToken.authenticator(), User.guardMiddleware())
        .delete("logout", use: user.logout)

    try app.register(collection: GameController())
}
