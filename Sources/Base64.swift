import Foundation


/// URI-safe base64 encode.
func base64URLencode(_ input: Data) -> String {
    let data = input.base64EncodedData(options: Data.Base64EncodingOptions(rawValue: 0))
    let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
    return string
        .replacingOccurrences(of: "+", with: "-", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "/", with: "_", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "=", with: "", options: NSString.CompareOptions(rawValue: 0), range: nil)
}

/// URI-safe base64 decode.
func base64URLdecode(_ input: String) -> Data? {
    let rem = input.characters.count % 4
    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: Character("="), count: amount)
    }
    let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "_", with: "/", options: NSString.CompareOptions(rawValue: 0), range: nil) + ending
    return Data(base64Encoded: base64, options: [])
}
