//
//  RunningInfo.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct RunningInfo: Codable {
   let date: String
   let course: [String]?
   let timeTaking: Int?
   let hardType: String?
   let supplies: [String]?
   let reward: String?
}

