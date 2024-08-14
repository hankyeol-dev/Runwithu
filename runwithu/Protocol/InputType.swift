//
//  InputType.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

protocol InputTypeProtocol {
    var byDictionary: Dictionary<String, String> { get }
}

extension InputTypeProtocol {
    var byDictionary: Dictionary<String, String> {
        var output: [String: String] = [:]
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            output[child.label ?? ""] = "\(child.value)"
        }
        
        return output
    }
}
