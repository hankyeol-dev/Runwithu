//
//  AuthEndPoint.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

enum AuthEndPoint: EndPointProtocol {
   
   case refreshToken(input: RefreshTokenInput)
   
   var path: String {
      return "/auth"
   }
   
   var endPoint: String {
      return "/refresh"
   }
   
   var method: NetworkMethod {
      return .get
   }
   
   var headers: [String : String]? {
      switch self {
      case let .refreshToken(input):
         return [
            AppEnvironment.headerContentKey: AppEnvironment.headerContentJsonValue,
            AppEnvironment.headerAuthKey: input.accessToken,
            AppEnvironment.headerRefreshKey: input.refreshToken
         ]
      }
   }
   
   var parameters: [URLQueryItem]? {
      return nil
   }
   
   var body: Data? {
      return nil
   }
}
