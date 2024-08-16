//
//  CreateRunningGroupInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct CreateRunningGroupInput: PostInputTypeProtocol {
   let productId: ProductIds = .runwithu_running_group
   let title: String
   let content: String
   let entryLimit: Int
   let mainSpot: String
   let runningHardType: [RunningHardType]
}
