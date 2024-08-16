//
//  EpilogueInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct EpilogueInput: PostInputTypeProtocol {
   let productId: ProductIds
   let title: String
   let content: String
   let communityType: PostsCommunityType = .epilogue
   let runningInfo: RunningInfo
   let invitationId: String?
}
