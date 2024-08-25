//
//  EpilogueInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct EpilogueInput: PostInputTypeProtocol {
   let productId: ProductIds
   var title: String
   var content: String
   let communityType: PostsCommunityType = .epilogue
   var runningInfo: RunningInfo?
   var invitationId: String?
}
