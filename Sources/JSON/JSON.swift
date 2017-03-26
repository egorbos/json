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

import Foundation

/// The type of data represented in JSON format.
public enum JSONType: Int {

    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown

}

/// JSON - The structure for representing json data.
public struct JSON {

    // MARK: Properties, initialization, deinitialization

    /// Private JSON value, example:
    /// { "name" : "Database", "encoding" : 4, "tables" : { "Shops" : { "columns" : [] }}}
    fileprivate var _value: Any = NSNull()

    /// Returns: _value property.
    /// Set: type property of JSON, and _value property.
    fileprivate(set) public var value: Any {
        get {
            return _value
        }
        set {
            _value = newValue

            switch newValue {
            case let number as NSNumber.FloatLiteralType:
                rawNumber = NSNumber(floatLiteral: number)
                type = .number
            case let number as NSNumber.IntegerLiteralType:
                rawNumber = NSNumber(integerLiteral: number)
                type = .number
            case let bool as Bool:
                rawBool = bool
                type = .bool
            case let string as String:
                rawString = string
                type = .string
            case _ as NSNull:
                type = .null
            case _ as [JSON]:
                type = .array
            case nil:
                type = .null
            case let array as [Any]:
                rawArray = array
                type = .array
            case let dictionary as [String : Any]:
                rawDictionary = dictionary
                type = .dictionary
            default:
                type = .unknown
            }
        }
    }

    /// The type of data represented in JSON format (represents JSONType enum).
    fileprivate(set) public var type: JSONType = .null

    /// Raw represents value, if data type is dictionary.
    fileprivate var rawDictionary: [String: Any] = [:]

    /// Raw represents value, if data type is array.
    fileprivate var rawArray: [Any] = []

    /// Raw represents value, if data type is bool.
    fileprivate var rawBool: Bool = false

    /// Raw represents value, if data type is number.
    fileprivate var rawNumber: NSNumber = -1

    /// Raw represents value, if data type is string.
    fileprivate var rawString: String = ""

    /// Initialization.
    ///
    /// - Parameter object: The object that needs to be represent in the JSON format.
    ///
    public init(_ object: Any) {
        switch object {
        case let object as [JSON]:
            self.init(array: object)
        case let object as [String: JSON]:
            self.init(dictionary: object)
        case let object as Data:
            self.init(data: object)
        default:
            self.init(jsonObject: object)
        }
    }

    /// Initialization.
    ///
    /// - Parameter data: Data which need to be represent in JSON format.
    ///
    /// - Note: If data represent a valid object of json, then return JSON object.
    ///         Otherwise return null JSON.
    ///
    fileprivate init(data: Data) {
        do {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            self.init(jsonObject: json)
        } catch {
            self.init(NSNull())
        }
    }

    /// Initialization.
    ///
    /// - Parameter dictionary: Dictionary [String: JSON] format.
    ///
    fileprivate init(dictionary: [String: JSON]) {
        var newDictionary = [String: Any](minimumCapacity: dictionary.count)
        for (key, json) in dictionary {
            newDictionary[key] = json.value
        }
        self.init(newDictionary)
    }

    /// Initialization.
    ///
    /// - Parameter array: Array of JSON objects.
    ///
    fileprivate init(array: [JSON]) {
        self.init(array.map { $0.value })
    }

    /// Initialization.
    ///
    /// - Parameter jsonObject: Object in the JSON format.
    ///
    fileprivate init(jsonObject: Any) {
        self.value = jsonObject
    }

}

extension JSON {

    // MARK: Subscript

    /// If the type of the provided data of json - the dictionary,
    /// returns value for key. Example: json["testkey"]
    ///
    /// - Parameter key: The key for which it is necessary to return value.
    ///
    public subscript(_ key: String) -> JSON {
        if type == .dictionary {
            return JSON(rawDictionary[key] as Any)
        }
        return JSON(NSNull())
    }

    /// If the type of the provided data of json - the array,
    /// returns value for index. Example: json[3]
    ///
    /// - Parameter index: The index for which it is necessary to return value.
    ///
    public subscript(_ index: Int) -> JSON {
        if type == .array {
            return JSON(rawArray[index])
        }
        return JSON(NSNull())
    }

}

extension JSON {

    // MARK: Properties for casts json value to Foundation data types

    public var dictionary: [String : Any]? {
        guard type == .dictionary else {
            return nil
        }
        return rawDictionary
    }

    public var array: [Any]? {
        guard type == .array else {
            return nil
        }
        return rawArray
    }

    public var string: String? {
        guard let string = value as? String else {
            return nil
        }
        return string
    }

    public var bool: Bool? {
        switch type {
        case .number:
            return number?.boolValue
        case .string:
            let decimal = NSDecimalNumber(string: value as? String)
            return decimal.boolValue
        case .bool:
            return rawBool
        default:
            return nil
        }
    }

    public var number: NSNumber? {
        switch type {
        case .number:
            return rawNumber
        case .string:
            let decimal = NSDecimalNumber(string: value as? String)
            return decimal
        case .bool:
            return NSNumber(value: rawBool ? 1 : 0)
        default:
            return nil
        }
    }

    public var int: Int? {
        guard let num = number else {
            return nil
        }
        return num.intValue
    }

    public var uint: UInt? {
        guard let num = number else {
            return nil
        }
        return num.uintValue
    }

    public var float: Float? {
        guard let num = number else {
            return nil
        }
        return num.floatValue
    }

    public var double: Double? {
        guard let num = number else {
            return nil
        }
        return num.doubleValue
    }

}
