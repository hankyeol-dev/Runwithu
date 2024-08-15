//
//  NetworkErrors.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

enum NetworkErrors: Error {
   case invalidURL
   case invalidRequest
   case invalidResponse
   case invalidAccessToken
   case invalidAccess
   case existEmail
   case needToRefreshToken
   case dataNotFound
   
   var byErrorMessage: String {
      switch self {
      case .invalidURL:
         return Text.ErrorMessage.INVALIDURL.rawValue
      case .invalidRequest:
         return Text.ErrorMessage.INVALIDREQUEST.rawValue
      case .invalidResponse:
         return Text.ErrorMessage.INVALIDRESPONSE.rawValue
      case .invalidAccessToken:
         return Text.ErrorMessage.INVALIDTOKEN.rawValue
      case .invalidAccess:
         return Text.ErrorMessage.INVALIDACCESS.rawValue
      case .existEmail:
         return Text.ErrorMessage.EXISTEMAIL.rawValue
      case .needToRefreshToken:
         return ""
      case .dataNotFound:
         return Text.ErrorMessage.DATANOTFOUND.rawValue
      }
   }
}