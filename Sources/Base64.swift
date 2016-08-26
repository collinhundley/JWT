import Foundation


/// URI-safe base64 encode.
func base64URLencode(_ input: Data) -> String {
    let data = input.base64EncodedData()
    let string = String(data: data, encoding: String.Encoding.utf8)!
    return string
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

/// URI-safe base64 decode.
func base64URLdecode(_ input: String) -> Data? {
    let rem = input.characters.count % 4
    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: Character("="), count: amount)
    }
    let base64 = input.replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/") + ending
    return Data(base64Encoded: base64, options: [])
}
