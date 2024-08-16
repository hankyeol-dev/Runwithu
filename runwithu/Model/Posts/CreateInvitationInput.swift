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
   let owner: String
   let invited: [String]
   let runningInfo: RunningInfo
}
