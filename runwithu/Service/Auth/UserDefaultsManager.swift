//
//  UserDefaultsManager.swift
//  runwithu
//
//  Created by 강한결 on 8/28/24.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T> {
   private let standard = UserDefaults.standard
   private let key: AppEnvironment.UserDefaultsKeys
   let defaultValue: T
   
   init(key: AppEnvironment.UserDefaultsKeys, defaultValue: T) {
      self.key = key
      self.defaultValue = defaultValue
   }
   
   var wrappedValue: T {
      get {
         standard.value(forKey: key.rawValue) as? T ?? defaultValue
      }
      
      set {
         standard.setValue(newValue, forKey: key.rawValue)
      }
   }
}

struct UserDefaultSetting {
   @UserDefaultsWrapper(key: .isAutoLogin, defaultValue: false)
   var isAutoLogin: Bool
   
   @UserDefaultsWrapper(key: .userId, defaultValue: "")
   var userId: String
   
   @UserDefaultsWrapper(key: .userEmail, defaultValue: "")
   var userEmail: String
   
   @UserDefaultsWrapper(key: .userPassword, defaultValue: "")
   var userPassword: String
}

actor UserDefaultsManager {
   static let shared = UserDefaultsManager()
   
   private let networkManager = NetworkService.shared
   private let tokenManager = TokenManager.shared
   private var userSetting = UserDefaultSetting()
   
   private init() {}
   
   func registerAutoLogin(by isAutoLogin: Bool) {
      userSetting.isAutoLogin = isAutoLogin
   }
   
   func registerUserId(by userId: String) {
      userSetting.userId = userId
   }
   
   func registerUserEmail(by userEmail: String) {
      userSetting.userEmail = userEmail
   }
   
   func registerUserPassword(by userPassword: String) {
      userSetting.userPassword = userPassword
   }
   
   func getAutoLoginState() -> Bool {
      return userSetting.isAutoLogin
   }
   
   func getUserId() -> String {
      return userSetting.userId
   }
   
   func getUserEmail() -> String {
      return userSetting.userEmail
   }
   
   func getUserPassword() -> String {
      return userSetting.userPassword
   }
   
   func autoLogin() async -> Bool {
      do {
         let result = try await networkManager.request(
            by: UserEndPoint.login(input: .init(
               email: userSetting.userEmail,
               password: userSetting.userPassword)
            ),
            of: LoginOutput.self)
         
         let access = await tokenManager.registerAccessToken(by: result.accessToken)
         let refresh = await tokenManager.registerRefreshToken(by: result.refreshToken)
         
         if access && refresh {
            return true
         } else {
            return false
         }
      } catch {
         return false
      }
   }
}
