import MongoKitten
import Sessions
import Vapor
import Crypto

/// Stores the sessions in MongoDB
public class MongoSessions : SessionsProtocol {
    /// The collection to store sessions in
    let collection: MongoKitten.Collection
    
    /// Creates a session storage around a collection
    public init(in collection: MongoKitten.Collection) {
        self.collection = collection
    }
    
    /// Creates a session storage around the `_sessions` collection in this database
    public init(in database: MongoKitten.Database) {
        self.collection = database["_sessions"]
    }
    
    /// Creates a new session token
    public func makeIdentifier() throws -> String {
        return try Crypto.Random.bytes(count: 20).base64Encoded.makeString()
    }
    
    /// Gets the session for this token
    public func get(identifier: String) throws -> Session? {
        guard var sessionDocument = try collection.findOne("_id" == identifier) else {
            return nil
        }
        
        sessionDocument.removeValue(forKey: "_id")
        
        return Session(identifier: identifier, data: Node([:], in: sessionDocument))
    }
    
    /// Sets a new session's values
    public func set(_ session: Session) throws {
        try collection.update("_id" == session.identifier, to: ["_id" : session.identifier] + session.document, upserting: true)
    }
    
    /// Destroys a session
    public func destroy(identifier: String) throws {
        try collection.remove("_id" == identifier)
    }
}

extension Session {
    /// The session storage (BSON required)
    public var document: Document {
        get {
            if let bytes = self.data.bytes {
                return Document(data: bytes)
            }
            
            return [:]
        }
        set {
            self.data = Node.bytes(newValue.bytes)
        }
    }
}

extension Document : Context {}
