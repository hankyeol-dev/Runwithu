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
