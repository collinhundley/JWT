import XCTest
@testable import JWT

class JWTTests: XCTestCase {
    func testJWT() {
        let input1 = "12345"
        let input2 = 123.8
        let jwt = JWT.encode(payload: ["test1" : input1, "test2" : input2], algorithm: Algorithm.hs512("thisisasecret"))
        let payload = try! JWT.decode(jwt, algorithm: Algorithm.hs512("thisisasecret"))
        let output1 = payload["test1"] as! String
        let output2 = payload["test2"] as! Double
        XCTAssertEqual(input1, output1)
        XCTAssertEqual(input2, output2)
    }


    static var allTests : [(String, (JWTTests) -> () throws -> Void)] {
        return [
            ("testJWT", testJWT),
        ]
    }
}
