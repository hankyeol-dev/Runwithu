//
//  Extension+Date.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

extension Date {
   func formattedRunningDate() -> String {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "ko_KR")
      formatter.dateFormat = "yyyy-MM-dd E요일 a hh시 mm분"
      return formatter.string(from: self)
   }
}

extension String {
   func calcBetweenDayAndHour() -> DateComponents? {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      formatter.locale = Locale(identifier: "ko_KR")
      
      if let date = formatter.date(from: self.formattedCreatedAt()) {
         return Calendar.current.dateComponents([.day, .hour], from: date, to: .now)
      }
      
      return nil
   }
   
   func formattedCreatedAt() -> String {
      return String(self.split(separator: "T").joined(separator: " ").split(separator: ".").joined().prefix(10))
   }
   
   func formattedRunningDateString() -> String? {
      if let date = self.split(separator: " ").map({ String($0) }).first {
         return date
      } else {
         return nil
      }
   }
}
