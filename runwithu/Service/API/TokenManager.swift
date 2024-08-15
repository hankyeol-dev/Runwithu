//
//  TokenManager.swift
//  runwithu
//
//  Created by 강한결 on 8/15/24.
//

import Foundation

actor TokenManager {
   static let shared = TokenManager()
   
   private enum encryptKeys: String {
      case access = "accessKey"
      case refresh = "refreshKey"
   }
   
   private init() {}
   
   // MARK: public methods
   // -
   
   func registerAccessToken(by token: String) -> Bool {
      return registerToken(by: .access, for: token)
   }
   
   func registerRefreshToken(by token: String) -> Bool {
      return registerToken(by: .refresh, for: token)
   }
   
   func readAccessToken() throws -> String {
      do {
         return try readToken(by: .access)
      } catch {
         throw TokenErrors.notFoundTokenError
      }
   }
   
   func refreshToken() async -> Bool {
      do {
         let access = try readAccessToken()
         let refresh = try readRefreshToken()
         let refreshTokenInput: RefreshTokenInput = .init(accessToken: access, refreshToken: refresh)
         
         let newAccessToken = try await NetworkService.shared.request(
            by: AuthEndPoint.refreshToken(input: refreshTokenInput),
            of: RefreshTokenOutput.self
         ).accessToken
         
         return registerAccessToken(by: newAccessToken)
      } catch {
         return false
      }
   }
   
   
   // MARK: private methods
   // -
   
   private func registerToken(by key: encryptKeys, for token: String) -> Bool {
      let convertedToken = token.data(using: .utf8)
      
      if let convertedToken {
         let keychainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: convertedToken
         ]
         
         // 혹시 이미 해당 키로 등록된 token이 있을 가능성을 배제하기 위해 삭제 먼저 진행
         SecItemDelete(keychainQuery)
         
         let status = SecItemAdd(keychainQuery, .none)
         
         guard status == errSecSuccess else {
            return false
         }
         return true
         
      } else {
         return false
      }
   }
   
   private func readToken(by key: encryptKeys) throws -> String {
      let keychainQuery: NSDictionary = [
         kSecClass: kSecClassGenericPassword,
         kSecAttrAccount: key.rawValue,
         kSecMatchLimit: kSecMatchLimitOne,
         kSecReturnAttributes: true,
         kSecReturnData: true
      ]
      
      var item: AnyObject?
      
      let status = SecItemCopyMatching(keychainQuery, &item)
      
      guard status == errSecSuccess else {
         throw TokenErrors.keyChainSearchError(msg: printErrorScript(by: status))
      }
      
      guard let items = item as? NSDictionary,
            let data = items[kSecValueData] as? Data,
            let token = String(data: data, encoding: .utf8) else {
         
         throw TokenErrors.convertTokenError
      }
      
      return token
   }
      
   private func readRefreshToken() throws -> String {
      do {
         return try readToken(by: .refresh)
      } catch {
         throw TokenErrors.notFoundTokenError
      }
   }
   
   private func printErrorScript(by status: OSStatus) -> String {
      if let description = SecCopyErrorMessageString(status, nil) as? String {
         return description
      } else {
         return "알 수 없는 에러 발생"
      }
   }
}
