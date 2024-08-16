//
//  ProductEpilogueInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct ProductEpilogueInput: PostInputTypeProtocol {
   let productId: ProductIds
   let title: String
   let content: String
   let communityType: PostsCommunityType = .epilogue
   let productType: RunningProductType
   let productBrandType: RunningProductBrandType
   let rating: Int
   let purchasedLink: String?
}
