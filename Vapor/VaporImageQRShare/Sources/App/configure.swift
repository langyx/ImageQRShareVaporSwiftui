import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.http.server.configuration.hostname = "192.168.1.63"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.routes.defaultMaxBodySize = "10mb"
    try FileManager.default.createDirectory(at: URL(fileURLWithPath: app.directory.publicDirectory + "photos"), withIntermediateDirectories: true)
    // register routes
    try routes(app)
    
}
