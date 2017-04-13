/// Copyright 2017 Sergei Egorov
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
/// http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import XCTest
import Foundation

@testable import JSON

class JSONTests: XCTestCase {

    static var allTests : [(String, (JSONTests) -> () throws -> Void)] {
        return [
            ("testInitJsonWithData", testInitJsonWithData),
            ("testInitJsonWithBadData", testInitJsonWithBadData),
            ("testInitJsonWithJsonObject", testInitJsonWithJsonObject),
            ("testInitJsonWithJsonArray", testInitJsonWithJsonArray),
            ("testInitJsonWithJsonDictionary", testInitJsonWithJsonDictionary),
            ("testJsonTypes", testJsonTypes),
            ("testJsonSubscripts", testJsonSubscripts)
        ]
    }

    func testInitJsonWithData() throws {
        let data = "{ \"name\" : \"Mike\" }".data(using: .utf8)!
        let json = JSON(data)
        XCTAssertEqual(json.type, .dictionary)
        XCTAssertEqual(json["name"].string, "Mike")
    }

    func testInitJsonWithBadData() throws {
        let data = "{{{{ \"name\" : \"Mike\" }".data(using: .utf8)!
        let json = JSON(data)
        XCTAssertEqual(json.type, .null)
        XCTAssertNil(json["name"].string)
        XCTAssertNil(json[0].string)
    }

    func testInitJsonWithJsonObject() throws {
        let data = "{ \"name\" : \"Michael\" }".data(using: .utf8)!
        let jsonObject = JSON(data).value
        let json = JSON(jsonObject)
        XCTAssertEqual(json.type, .dictionary)
        XCTAssertEqual(json["name"].string, "Michael")
    }

    func testInitJsonWithJsonArray() throws {
        let oneData = "{ \"name\" : \"Ann\" }".data(using: .utf8)!
        let twoData = "{ \"name\" : \"John\" }".data(using: .utf8)!
        let jsonOne = JSON(oneData)
        let jsonTwo = JSON(twoData)
        let testJson = JSON([jsonOne, jsonTwo])
        XCTAssertEqual(testJson.type, .array)
        XCTAssertEqual(testJson[0]["name"].string, "Ann")
        XCTAssertEqual(testJson[1]["name"].string, "John")
    }

    func testInitJsonWithJsonDictionary() throws {
        let data = "{ \"name\" : \"Jake\" }".data(using: .utf8)!
        let json = JSON(data)
        let testJson = JSON(["test": json])
        XCTAssertEqual(testJson.type, .dictionary)
        XCTAssertEqual(testJson["test"]["name"].string, "Jake")
    }

    func testJsonTypes() throws {
        let object = "{ \"child\" : { \"name\" : \"Ann\", \"age\" : 5, \"student\" : false, \"temp\" : 36.6, \"friends\" : [\"Mike\", \"Frank\"] } }"
        let data = object.data(using: .utf8)!

        let json = JSON(data)

        XCTAssertEqual(json["child"].type, .dictionary)
        XCTAssertEqual(json["child"].dictionary?["name"] as? String, "Ann")

        XCTAssertEqual(json["child"]["name"].type, .string)
        XCTAssertEqual(json["child"]["name"].string, "Ann")

        XCTAssertEqual(json["child"]["age"].type, .number)
        XCTAssertEqual(json["child"]["age"].int, 5)

        XCTAssertEqual(json["child"]["temp"].type, .number)
        XCTAssertEqual(json["child"]["temp"].float, 36.6)

        XCTAssertEqual(json["child"]["student"].type, .bool)
        XCTAssertEqual(json["child"]["student"].bool, false)

        XCTAssertEqual(json["child"]["friends"].type, .array)
        XCTAssertEqual(json["child"]["friends"].array?[0] as? String, "Mike")
        XCTAssertEqual(json["child"]["friends"].array?[1] as? String, "Frank")
    }

    func testJsonSubscripts() throws {
        let data = "{ \"names\" : [\"Mike\", \"Frank\"] }".data(using: .utf8)!
        let json = JSON(data)
        XCTAssertEqual(json["names"].type, .array)
        XCTAssertEqual(json["names"][0].string, "Mike")
        XCTAssertEqual(json["names"][1].string, "Frank")
    }

    class Child: JSONRepresentable {
        let name = "Ann"
        let age = 5
        let student = false
        let temp = 36.6
        let friends = ["Mike", "Frank"]
    }

    func testJsonRepresentable() throws {
        let jsonString = "{\"child\":{\"name\":\"Ann\",\"age\":5,\"student\":false,\"temp\":36.6,\"friends\":[\"Mike\",\"Frank\"]}}"

        let test = ["child": Child()]

        guard let json = test.jsonString() else {
            XCTFail()
            return
        }

        XCTAssertEqual(jsonString, json)
    }

}
