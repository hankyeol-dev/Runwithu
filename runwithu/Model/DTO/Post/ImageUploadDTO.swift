//
//  ImageUploadDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct ImageUploadInput {
   let boundary: String = UUID().uuidString
   let files: [Data]
}

struct ImageUploadOutput: Decodable {
   let files: [String]
}
