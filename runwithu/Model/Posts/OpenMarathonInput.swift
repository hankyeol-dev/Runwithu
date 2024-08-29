//
//  OpenMarathonInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct OpenMarathonInput: PostInputTypeProtocol {
   let productId: ProductIds
   let title: String
   let content: String
   let communityType: PostsCommunityType = .open_self_marathons
   let runningInfo: RunningInfo
   let entryLimit: Int
   var isEntryDone: Bool
}
