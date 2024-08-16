//
//  EndPoint.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

protocol EndPointProtocol {
   var isNeedToken: Bool { get }
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
   
   func asURLRequest() async throws -> URLRequest {
      do {
         let url = try asURL()
         
         var request = URLRequest(url: url)
         
         request.httpMethod = method.rawValue
         
         if let headers {
            for (key, value) in headers {
               request.setValue(value, forHTTPHeaderField: key)
            }
            
            if isNeedToken {
               let accessToken = try await TokenManager.shared.readAccessToken()
               request.setValue(accessToken, forHTTPHeaderField: AppEnvironment.headerAuthKey)
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
   
   func asUploadURLRequest() async throws -> URLRequest {
      do {
         let url = try asURL()
         var request = URLRequest(url: url)
         
         request.httpMethod = method.rawValue
         
         if let headers {
            for (key, value) in headers {
               request.setValue(value, forHTTPHeaderField: key)
            }
            
            if isNeedToken {
               let accessToken = try await TokenManager.shared.readAccessToken()
               request.setValue(accessToken, forHTTPHeaderField: AppEnvironment.headerAuthKey)
            }
         }
                  
         return request
         
      } catch {
         throw NetworkErrors.invalidRequest
      }
   }
   
   func asMultipartFileData(for boundary: String, key: String, by value: Data, filename: String) -> Data {
      let crlf = "\r\n"
      
      var dataSet = Data()
      
      dataSet.append("--\(boundary)\(crlf)".data(using: .utf8)!)
      dataSet.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\(crlf)".data(using: .utf8)!)
      dataSet.append("Content-Type: image/png\(crlf)\(crlf)".data(using: .utf8)!)
      dataSet.append(value)
      dataSet.append("\(crlf)".data(using: .utf8)!)
      dataSet.append("--\(boundary)--\(crlf)".data(using: .utf8)!)
      
      return dataSet
   }
   
   func asMultipartFileDatas(for boundary: String, key: String, values: [Data], filename: String) -> Data {
      let crlf = "\r\n"
      let dataSet = NSMutableData()
      
      values.forEach {
         dataSet.append("--\(boundary)\(crlf)".data(using: .utf8)!)
         dataSet.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\(crlf)".data(using: .utf8)!)
         dataSet.append("Content-Type: image/png\(crlf)\(crlf)".data(using: .utf8)!)
         dataSet.append($0)
         dataSet.append("\(crlf)".data(using: .utf8)!)
      }
      dataSet.append("--\(boundary)--\(crlf)".data(using: .utf8)!)
            
      return dataSet as Data
   }
}
