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
   case readMyProfile
   case readAnotherProfile(input: ProfileInput)
   case searchUserByNick(input: SearchUserByNickInput)
   case updateProfile(input: ProfileUpdateInput)
   case updateProfileImage(input: ProfileImageUpdateInput)
   case follow(input: FollowInput)
   
   var isNeedToken: Bool {
      switch self {
      case .join, .login, .validEmail:
         return false
      default:
         return true
      }
   }
   
   var path: String {
      switch self {
      case .join, .login, .readMyProfile, .readAnotherProfile, .updateProfile, .updateProfileImage, .searchUserByNick:
         return "/users"
      case .validEmail:
         return "/validation"
      case .follow:
         return "/follow"
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
      case .readMyProfile, .updateProfile, .updateProfileImage:
         return "/me/profile"
      case .searchUserByNick:
         return "/search"
      case let .readAnotherProfile(input):
         return "/\(input.user_id)/profile"
      case let .follow(input):
         return "/\(input.user_id)"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .join, .login, .validEmail:
         return .post
      case .readMyProfile, .readAnotherProfile, .searchUserByNick:
         return .get
      case .updateProfile, .updateProfileImage:
         return .put
      case let .follow(input):
         return input.isFollowing ? .delete : .post
      }
   }
   
   var headers: [String : String]? {
      switch self {
      case let .updateProfileImage(input):
         return [AppEnvironment.headerContentKey: AppEnvironment.headerContentMultiValue + "; boundary=\(input.boundary)"]
      default:
         return [AppEnvironment.headerContentKey: AppEnvironment.headerContentJsonValue]
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      case let .searchUserByNick(input):
         return [
            URLQueryItem(name: "nick", value: input.nick)
         ]
      default:
         return nil
      }
   }
   
   var body: Data? {
      switch self {
      case let .join(input):
         return input.converToJSON()
      case let .login(input):
         return input.converToJSON()
      case let .validEmail(input):
         return input.converToJSON()
      case let .updateProfile(input):
         return input.converToJSON()
      case let .updateProfileImage(input):
         if let profile = input.profile {
            return asMultipartFileDatas(
               for: input.boundary,
               key: "profile",
               values: [profile],
               filename: "profileImage"
            )
         }
         return nil
      default:
         return nil
      }
   }

}

