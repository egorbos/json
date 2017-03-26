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

/// JSONRepresentable - The protocol for representation of objects in the form of json.
public protocol JSONRepresentable {
    var jsonValue: Any { get }
    var jsonObject: JSON { get }
    func jsonString(_ options: JSONSerialization.WritingOptions?) -> String?
}

extension JSONRepresentable {

    public var jsonValue: Any {
        var representation: [String: Any] = [:]

        for case let (label?, value) in Mirror(reflecting: self).children {
            switch value {
            case let value as JSONRepresentable:
                representation[label] = value.jsonValue

            case let value as NSObject:
                representation[label] = value

            case let value as [JSONRepresentable]:
                representation[label] = value.jsonValue

            default:
                break
            }
        }
        return representation
    }

    public func jsonString(_ opt: JSONSerialization.WritingOptions? = nil) -> String? {
        let representation = jsonValue

        guard JSONSerialization.isValidJSONObject(representation) else {
            return nil
        }

        do {
            guard let options = opt else {
                let data = try JSONSerialization.data(withJSONObject: representation)
                return String(data: data, encoding: .utf8)
            }
            let data = try JSONSerialization.data(withJSONObject: representation, options: options)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    public var jsonObject: JSON {
        return JSON(jsonValue)
    }

}
