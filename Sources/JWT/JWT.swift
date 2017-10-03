import Foundation
import Cryptor


public typealias Payload = [String : Any]

public enum Error: Swift.Error {
    case sign(String)
}

/// The supported Algorithms
public enum Algorithm: CustomStringConvertible {
    /// No algorithm (insecure)
    case none
    /// HMAC using SHA-256 hash algorithm
    case hs256(String)
    /// HMAC using SHA-384 hash algorithm
    case hs384(String)
    /// HMAC using SHA-512 hash algorithm
    case hs512(String)
    
    
    static func algorithm(_ name: String, key: String?) -> Algorithm? {
        if name == "none" {
            if key != nil {
                return nil  // We don't allow nil when we configured a key
            }
            return Algorithm.none
        } else if let key = key {
            if name == "HS256" {
                return .hs256(key)
            } else if name == "HS384" {
                return .hs384(key)
            } else if name == "HS512" {
                return .hs512(key)
            }
        }
        return nil
    }
    
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .hs256:
            return "HS256"
        case .hs384:
            return "HS384"
        case .hs512:
            return "HS512"
        }
    }
    
    /// Sign a message using the algorithm
    func sign(message: String) throws -> String {
        func signHS(_ key: String, algorithm: HMAC.Algorithm) throws -> String {
            guard let hmac = HMAC(using: algorithm, key: key).update(string: message) else {
                throw Error.sign("Failed to sign JWT: could not generate HMAC from given key.")
            }
            let digest = hmac.final()
            let data = Data(bytes: digest)
            return base64URLencode(data)
        }
        
        switch self {
        case .none:
            return ""
        case .hs256(let key):
            return try signHS(key, algorithm: HMAC.Algorithm.sha256)
        case .hs384(let key):
            return try signHS(key, algorithm: HMAC.Algorithm.sha384)
        case .hs512(let key):
            return try signHS(key, algorithm: HMAC.Algorithm.sha512)
        }
    }
    
    /// Verify a signature for a message using the algorithm
    func verify(message: String, signature: Data) -> Bool {
        guard let signed = try? sign(message: message) else {
            return false
        }
        return signed == base64URLencode(signature)
    }
}

// MARK: Encoding

/*** Encode a payload
 - parameter payload: The payload to sign.
 - parameter algorithm: The algorithm used to sign the payload.
 - returns: The JSON web token as a String
 */


/// Encode a payload.
///
/// - parameter payload:   The payload to sign.
/// - parameter algorithm: The algorithm to use for signing the payload.
///
/// - returns: The JSON web token as a String.
public func encode(payload: Payload, algorithm: Algorithm) throws -> String {
    func encodeJSON(payload: Payload) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions(rawValue: 0))
        return base64URLencode(data)
    }
    
    let header = try encodeJSON(payload: ["typ": "JWT", "alg": algorithm.description])
    let payload = try encodeJSON(payload: payload)
    let signingInput = "\(header).\(payload)"
    let signature = try algorithm.sign(message: signingInput)
    return "\(signingInput).\(signature)"
}

public class PayloadBuilder {
    
    var payload = Payload()
    
    public var issuer: String? {
        get {
            return payload["iss"] as? String
        }
        set {
            payload["iss"] = newValue
        }
    }
    
    public var audience: String? {
        get {
            return payload["aud"] as? String
        }
        set {
            payload["aud"] = newValue
        }
    }
    
    public var expiration: Date? {
        get {
            if let expiration = payload["exp"] as? TimeInterval {
                return Date(timeIntervalSince1970: expiration)
            }
            
            return nil
        }
        set {
            payload["exp"] = newValue?.timeIntervalSince1970
        }
    }
    
    public var notBefore: Date? {
        get {
            if let notBefore = payload["nbf"] as? TimeInterval {
                return Date(timeIntervalSince1970: notBefore)
            }
            
            return nil
        }
        set {
            payload["nbf"] = newValue?.timeIntervalSince1970
        }
    }
    
    public var issuedAt: Date? {
        get {
            if let issuedAt = payload["iat"] as? TimeInterval {
                return Date(timeIntervalSince1970: issuedAt)
            }
            
            return nil
        }
        set {
            payload["iat"] = newValue?.timeIntervalSince1970
        }
    }
    
    public subscript(key: String) -> Any? {
        get {
            return payload[key]
        }
        set {
            payload[key] = newValue
        }
    }
    
}

public func encode(algorithm: Algorithm, closure: ((PayloadBuilder) -> ())) throws -> String {
    let builder = PayloadBuilder()
    closure(builder)
    return try encode(payload:builder.payload, algorithm: algorithm)
}



