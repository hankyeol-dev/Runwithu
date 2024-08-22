//
//  RunningInfo.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct RunningInfo: Codable {
   var date: String
   var course: String?
   var timeTaking: Int?
   var hardType: String?
   var supplies: String?
   var reward: String?
   
   var byJsonString: String? {
      if let json = self.converToJSON(),
         let jsonString = String(data: json, encoding: .utf8) {
         return jsonString
      } else {
         return nil
      }
   }
}

