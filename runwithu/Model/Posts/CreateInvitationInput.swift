//
//  CreateInvitationInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct CreateInvitationInput: PostInputTypeProtocol {
   let productId: ProductIds = .runwithu_running_inviation
   let title: String
   let content: String
   let invited: [String]
   let runningInfo: RunningInfo
   
   var formatToPostsInput: PostsInput {
      
      return .init(
         product_id: productId.rawValue,
         title: title,
         content: content,
         content1: invited.joined(separator: " "),
         content2: runningInfo.byJsonString,
         content3: nil,
         content4: nil,
         content5: nil,
         files: nil
      )
   }
}
