import Vapor
@_exported import MongoKitten
@_exported import BSON

public final class Provider: Vapor.Provider {
    public static let repositoryName: String = "mongokitten-provider"
    
    public let database: Database
    
    public init(config: Config) throws {
        self.database = try Database(config: config)
    }
    
    /// Called after the provider has initialized
    /// in the `Config.addProvider` call.
    public func boot(_ config: Config) throws {
        config.addConfigurable(cache: { config -> MongoCache in
            let cache = try config.mongoConfig(for: "cache")
            return try MongoCache(in: self.database[cache])
        }, name: "mongo")
        
        config.addConfigurable(sessions: { config -> MongoSessions in
            let sessions = try config.mongoConfig(for: "sessions")
            return MongoSessions(in: self.database[sessions])
        }, name: "mongo")
    }
    
    /// Called after the Droplet has initialized.
    public func boot(_ droplet: Droplet) throws {
        droplet.mongodb = self.database
    }
    
    /// Called before the Droplet begins serving
    /// which is @noreturn.
    public func beforeRun(_ droplet: Droplet) throws { }
}

extension Config {
    fileprivate func mongoConfig(for key: String) throws -> String {
        guard let mongo = self["mongo"] else {
            throw ConfigError.missingFile("mongo")
        }
        
        guard let value = mongo[key]?.string else {
            throw ConfigError.missing(
                key: [key],
                file: "mongo",
                desiredType: String.self
            )
        }
        
        return value
    }
}

extension Database: ConfigInitializable {
    public convenience init(config: Config) throws {
        let url = try config.mongoConfig(for: "url")
        
        try self.init(url)
    }
}

extension Droplet {
    public internal(set) var mongodb: Database? {
        get {
            return self.storage["mongokitten-provider-database"] as? Database
        }
        set {
            self.storage["mongokitten-provider-database"] = newValue
        }
    }
    
    public func assertMongoDB() throws -> Database {
        guard let mongodb = self.mongodb else {
            throw MongoError.notConnected
        }
        
        return mongodb
    }
}