//
//  ProductEpilogueInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct ProductEpilogueInput: PostInputTypeProtocol {
   var productId: ProductIds
   var title: String
   var content: String
   let communityType: PostsCommunityType = .epilogue
   var productType: String
   var productBrandType: String
   var rating: String?
   var purchasedLink: String?
}
