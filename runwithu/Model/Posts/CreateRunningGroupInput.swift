//
//  CreateRunningGroupInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct CreateRunningGroupInput: PostInputTypeProtocol {
   let productId: ProductIds = .runwithu_running_group
   var title: String
   var content: String
   var entryLimit: String
   var mainSpot: String
   var runningHardType: String
}
