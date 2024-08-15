//
//  JoinDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

struct JoinInput: Encodable {
  let email: String
  let password: String
  let nick: String
  let phoneNum: String?
  let birthDay: String?
}

struct JoinOutput: Decodable {
   let user_id: String
   let email: String
   let nick: String
}
