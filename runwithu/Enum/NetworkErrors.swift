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
   case needToRefreshAccessToken
   case needToRefreshRefreshToken
   case dataNotFound
   case noUploadData
   case invalidUpload
   case overlapUsername
   
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
      case .needToRefreshAccessToken:
         return Text.ErrorMessage.NEED_TO_REFRESH_ACCESSTOKEN.rawValue
      case .needToRefreshRefreshToken:
         return Text.ErrorMessage.NEED_TO_REFRESH_REFRESHTOKEN.rawValue
      case .dataNotFound:
         return Text.ErrorMessage.DATANOTFOUND.rawValue
      case .noUploadData:
         return Text.ErrorMessage.NEED_TO_CONFIGURE_UPLOAD_SOURCE.rawValue
      case .invalidUpload:
         return Text.ErrorMessage.INVALID_UPLOAD.rawValue
      default:
         return ""
      }
   }
}
