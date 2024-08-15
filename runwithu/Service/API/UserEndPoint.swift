//
//  UserEndPoint.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

enum UserEndPoint: EndPointProtocol {
   case join(input: JoinInput)
   case login(input: LoginInput)
   case validEmail(input: ValidEmailInput)
   
   var isNeedToken: Bool {
      switch self {
      case .join, .login, .validEmail:
         return false
      }
   }
   
   var path: String {
      switch self {
      case .join, .login:
         return "/users"
      case .validEmail:
         return "/validation"
      }
   }
   
   var endPoint: String {
      switch self {
      case .join:
         return "/join"
      case .login:
         return "/login"
      case .validEmail:
         return "/email"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .join, .login, .validEmail:
         return .post
      }
   }
   
   var headers: [String : String]? {
      switch self {
      default:
         return [AppEnvironment.headerContentKey: AppEnvironment.headerContentJsonValue]
      }
   }
   
   var parameters: [URLQueryItem]? {
      return nil
   }
   
   var body: Data? {
      switch self {
      case let .join(input):
         return input.converToJSON()
      case let .login(input):
         return input.converToJSON()
      case let .validEmail(input):
         return input.converToJSON()
      }
   }
   
   
}

