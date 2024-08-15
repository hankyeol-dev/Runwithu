//
//  Network.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

final class NetworkService {
   private let session = {
      let config = URLSessionConfiguration.default
      config.httpAdditionalHeaders = [
         AppEnvironment.headerSecretKey: AppEnvironment.headerSecretValue
      ]
      return URLSession(configuration: config)
   }()
   
   static let shared = NetworkService()
   
   private init() {}
   
   func request<D: Decodable>(
      by endPoint: EndPointProtocol,
      of outputType: D.Type
   ) async throws -> D {
      let request = try endPoint.asURLRequest()
      let (data, response) = try await session.data(for: request)
            
      do {
         return try await handleResponse(data: data, response: response)
      } catch NetworkErrors.needToRefreshToken {
         await self.handleRefreshToken()
         return try await self.request(by: endPoint, of: outputType)
      } catch {
         return try await handleResponse(data: data, response: response)
      }
   }
}

extension NetworkService {
   private func handleResponse<D: Decodable>(data: Data, response: URLResponse) async throws -> D {
      guard let response = response as? HTTPURLResponse else {
         throw NetworkErrors.invalidResponse
      }
      
      try await handleStatusCode(statusCode: response.statusCode)
            
      do {
         return try JSONDecoder().decode(D.self, from: data)
      } catch {
         throw NetworkErrors.dataNotFound
      }
   }
   
   private func handleStatusCode(statusCode: Int) async throws {
      switch statusCode {
      case 400:
         throw NetworkErrors.invalidRequest
      case 401:
         throw NetworkErrors.invalidAccessToken
      case 403:
         throw NetworkErrors.invalidAccess
      case 409:
         throw NetworkErrors.invalidResponse
      case 419:
         throw NetworkErrors.needToRefreshToken
      default:
         break
      }
   }
   
   private func handleRefreshToken() async {
      // 1. token 값을 조회한다.
      // 2. refresh token 값도 조회한다.
      // 3. 이 로직에 들어왔다는 것은 refresh가 필요하다는 뜻!
   }
}
