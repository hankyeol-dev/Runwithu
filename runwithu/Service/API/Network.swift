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
   private let tokenManager = TokenManager.shared
   
   static let shared = NetworkService()
   
   private init() {}
   
   func request<D: Decodable>(
      by endPoint: EndPointProtocol,
      of outputType: D.Type
   ) async throws -> D {
      let request = try await endPoint.asURLRequest()
      let (data, response) = try await session.data(for: request)
            
      do {
         return try await handleResponse(data: data, response: response)
      } catch NetworkErrors.needToRefreshAccessToken {
         let refreshResult = await tokenManager.refreshToken()
         if refreshResult {
            return try await self.request(by: endPoint, of: outputType)
         } else {
            throw NetworkErrors.needToRefreshRefreshToken
         }
      } catch {
         return try await handleResponse(data: data, response: response)
      }
   }
   
   func request(by endPoint: EndPointProtocol) async throws {
      let request = try await endPoint.asURLRequest()
      let (_, response) = try await session.data(for: request)
      
      guard let response = response as? HTTPURLResponse else {
         throw NetworkErrors.invalidResponse
      }
      
      do {
         if !(200..<300).contains(response.statusCode) {
            try await handleStatusCode(statusCode: response.statusCode)
         }
      } catch NetworkErrors.needToRefreshAccessToken {
         let refreshResult = await tokenManager.refreshToken()
         if refreshResult {
            return try await self.request(by: endPoint)
         } else {
            throw NetworkErrors.needToRefreshRefreshToken
         }
      } catch {
         throw NetworkErrors.invalidRequest
      }
   }
   
   func requestImage(by imageURL: String, imageHandler: @escaping (Data?) -> Void) async throws {
      let request = try await PostEndPoint.getPostImage(input: .init(imageURL: imageURL)).asURLRequest()
      let (data, response) = try await session.data(for: request)
      
      guard let response = response as? HTTPURLResponse else {
         throw NetworkErrors.invalidResponse
      }
      
      do {
         if !(200..<300).contains(response.statusCode) {
            try await handleStatusCode(statusCode: response.statusCode)
         }
         imageHandler(data)
      } catch NetworkErrors.needToRefreshAccessToken {
         let refreshResult = await tokenManager.refreshToken()
         if refreshResult {
            return try await self.requestImage(by: imageURL, imageHandler: imageHandler)
         } else {
            throw NetworkErrors.needToRefreshRefreshToken
         }
      } catch {
         throw NetworkErrors.invalidRequest
      }
   }
   
   func upload<D: Decodable>(
      by endPoint: EndPointProtocol,
      of outputType: D.Type
   ) async throws -> D {
      do {
         let request = try await endPoint.asUploadURLRequest()
         
         guard let uploadData = endPoint.body else {
            throw NetworkErrors.noUploadData
         }
         
         let (data, response) = try await session.upload(for: request, from: uploadData)
         
         return try await handleResponse(data: data, response: response)
         
      } catch NetworkErrors.needToRefreshAccessToken {
         let refreshResult = await tokenManager.refreshToken()
         if refreshResult {
            return try await self.upload(by: endPoint, of: outputType)
         } else {
            throw NetworkErrors.needToRefreshRefreshToken
         }
      } catch {
         throw NetworkErrors.invalidUpload
      }
   }
}

extension NetworkService {
   private func handleResponse<D: Decodable>(data: Data, response: URLResponse) async throws -> D {
      guard let response = response as? HTTPURLResponse else {
         throw NetworkErrors.invalidResponse
      }
      
      if !(200..<300).contains(response.statusCode) {
         try await handleStatusCode(statusCode: response.statusCode)
      }
            
      do {
         return try JSONDecoder().decode(D.self, from: data)
      } catch {
         dump(error)
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
      case 410:
         throw NetworkErrors.dataNotFound
      case 418:
         throw NetworkErrors.needToRefreshRefreshToken
      case 419:
         throw NetworkErrors.needToRefreshAccessToken
      case 444:
         throw NetworkErrors.invalidURL
      case 445:
         throw NetworkErrors.invalidAccess
      default:
         break
      }
   }
}
