//
//  EndPoint.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

protocol EndPointProtocol {
   var path: String { get }
   var endPoint: String { get }
   var method: NetworkMethod { get }
   var headers: [String: String]? { get }
   var parameters: [URLQueryItem]? { get }
   var body: Data? { get }
}

extension EndPointProtocol {
   func asURL() throws -> URL {
      guard var component = URLComponents(string: AppEnvironment.baseURL + path + endPoint) else {
         throw NetworkErrors.invalidURL
      }

      component.queryItems = parameters

      guard let url = component.url else {
         throw NetworkErrors.invalidURL
      }
      
      return url
   }
   
   func asURLRequest() throws -> URLRequest {
      do {
         let url = try asURL()
         var request = URLRequest(url: url)
         
         request.httpMethod = method.rawValue
         
         if let headers {
            for (key, value) in headers {
               request.setValue(value, forHTTPHeaderField: key)
            }
         }
         
         if let body {
            request.httpBody = body
         }
         
         return request
      } catch {
         throw NetworkErrors.invalidRequest
      }
   }
}
