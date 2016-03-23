//
//  SQLValueTransformer.swift
//  Pods
//
//  Created by Abner on 16/3/23.
//
//

import Foundation

public protocol SQLValue {
    func toSqlValue() -> String
}

public class SQLValueTransformer {
    public static func transform(value: Any?) -> String {
        guard let value = value else { return "null" }
        let mirror = Mirror(reflecting: value)
        
        let toString = { (value: Any) -> String in
            switch (value) {
            case let v as SQLValue: return v.toSqlValue()
            case let v as String:
                let str = v.stringByReplacingOccurrencesOfString("'", withString: "''")
                return "'\(str)'"
            case let v as NSDate: return "\(Int(v.timeIntervalSince1970 * 1000))"
            case let v as Bool: return v ? "1" : "0"
            default: return "\(value)"
            }
        }
        
        if let displayStyle = mirror.displayStyle {
            switch (displayStyle) {
            case .Optional:
                let optional = mirror.descendant("Some")
                return optional == nil ? "null" : toString(optional!)
            default:
                return toString(value)
            }
        } else {
            return toString(value)
        }
    }
}
