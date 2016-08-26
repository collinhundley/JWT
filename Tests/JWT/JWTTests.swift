import XCTest
@testable import JWT

class JWTTests: XCTestCase {
    func testJWT() {
        let input = "12345"
        let jwt = JWT.encode(payload: ["test" : input], algorithm: Algorithm.hs512("thisisasecret"))
        let output = try! JWT.decode(jwt, algorithm: Algorithm.hs512("thisisasecret"))["test"] as! String
        XCTAssertEqual(input, output)
    }


    static var allTests : [(String, (JWTTests) -> () throws -> Void)] {
        return [
            ("testJWT", testJWT),
        ]
    }
}
