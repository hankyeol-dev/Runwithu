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
   
   var isRunningToday: Bool {
      if let dateString = date.formattedRunningDateString() {
         let dateFormatter = DateFormatter()
         dateFormatter.locale = Locale(identifier: "ko_KR")
         dateFormatter.dateFormat = "yyyy-MM-dd"
         if let date = dateFormatter.date(from: dateString) {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            if let day = Calendar.current.dateComponents([.day], from: today, to: components).day, day == 0 {
               return true
            }
         }
      }
      
      return false
   }
   
   var isRunningInFuture: Bool {
      if let dateString = date.formattedRunningDateString() {
         let dateFormatter = DateFormatter()
         dateFormatter.locale = Locale(identifier: "ko_KR")
         dateFormatter.dateFormat = "yyyy-MM-dd"
         if let date = dateFormatter.date(from: dateString) {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            if let day = Calendar.current.dateComponents([.day], from: today, to: components).day, day > 0 {
               return true
            }
         }
      }
      
      return false
   }
}

