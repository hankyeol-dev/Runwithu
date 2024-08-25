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

extension Decodable {
   func convertToData<D: Decodable>(for property: String, of: D.Type) -> D? {
      do {
        let data = Data(property.utf8)
         return try JSONDecoder().decode(of, from: data)
      } catch {
         return nil
      }
   }
}
