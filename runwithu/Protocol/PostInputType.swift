//
//  PostInputType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

protocol PostInputTypeProtocol {
   var productId: ProductIds { get }
   var title: String { get }
   var content: String { get }
}
