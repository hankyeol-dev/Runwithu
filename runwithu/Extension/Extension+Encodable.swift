//
//  Extension+Encodable.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

extension Encodable {
  func converToJSON() -> Data? {
    do {
      return try JSONEncoder().encode(self)
    } catch {
      return nil
    }
  }
}
