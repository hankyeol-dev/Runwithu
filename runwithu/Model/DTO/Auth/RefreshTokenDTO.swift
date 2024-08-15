//
//  RefreshTokenDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

struct RefreshTokenInput: Encodable {
   let accessToken: String
   let refreshToken: String
}

struct RefreshTokenOutput: Decodable {
   let accessToken: String
}
