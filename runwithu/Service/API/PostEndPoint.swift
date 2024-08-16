//
//  PostEndPoint.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

enum PostEndPoint: EndPointProtocol {
   case postImageUpload(input: ImageUploadInput)
   case posts(input: PostsInput)
   
   var isNeedToken: Bool {
      return true
   }
   
   var path: String {
      switch self {
      case .postImageUpload, .posts:
         return "/posts"
      }
   }
   
   var endPoint: String {
      switch self {
      case .postImageUpload:
         return "/files"
      case .posts:
         return ""
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .postImageUpload, .posts:
         return .post
      }
   }
   
   var headers: [String : String]? {
      switch self {
      case let .postImageUpload(input):
         return [
            AppEnvironment.headerContentKey
            : AppEnvironment.headerContentMultiValue + "; boundary=\(input.boundary)"
         ]
      default:
         return [AppEnvironment.headerContentKey: AppEnvironment.headerContentJsonValue]
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      default:
         return nil
      }
   }
   
   var body: Data? {
      switch self {
      case let .postImageUpload(input):
         return asMultipartFileDatas(for: input.boundary, key: "files", values: input.files, filename: "postImage")
      case let .posts(input):
         return input.converToJSON()
      }
   }
}
