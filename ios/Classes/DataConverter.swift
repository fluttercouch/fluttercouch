//
//  DataConverter.swift
//  fluttercouch
//
//  Created by Saltech Systems on 5/10/19.
//

import Foundation


class DataConverter {
    static func convertSETValue(_ value: Any?) -> Any? {
        switch value {
        case let dict as Dictionary<String, Any>:
            return convertSETDictionary(dict)
        case let array as Array<Any>:
            return convertSETArray(array)
        case let bool as NSNumber:
            if (bool === kCFBooleanTrue || bool === kCFBooleanFalse) {
                return bool === kCFBooleanTrue
            } else {
                return value
            }
        default:
            return value
        }
    }
    
    static func convertSETDictionary(_ dictionary: [String: Any]?) -> [String: Any]? {
        guard let dict = dictionary else {
            return nil
        }
        
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = DataConverter.convertSETValue(value)
        }
        return result
    }
    
    static func convertSETArray(_ array: [Any]?) -> [Any]? {
        guard let a = array else {
            return nil
        }
        
        var result: [Any] = [];
        for v in a {
            result.append(DataConverter.convertSETValue(v)!)
        }
        return result
    }
}
