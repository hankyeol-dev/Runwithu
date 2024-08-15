//
//  ValidEmailDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

struct ValidEmailInput: Encodable {
  let email: String
}

struct ValidEmailOutput: Decodable {
   let message: String
}
