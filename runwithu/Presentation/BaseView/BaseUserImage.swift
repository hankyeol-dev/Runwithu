//
//  BaseUserImage.swift
//  runwithu
//
//  Created by 강한결 on 8/27/24.
//

import UIKit

final class BaseUserImage: UIImageView {
   override init(frame: CGRect) {
      super.init(frame: frame)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   convenience init(size: CGFloat, borderW: CGFloat? = nil, borderColor: UIColor? = nil) {
      self.init(frame: .zero)
      layer.cornerRadius = size / 2
      layer.masksToBounds = true
      contentMode = .scaleToFill
      
      if let borderW, let borderColor {
         layer.borderWidth = borderW
         layer.borderColor = borderColor.cgColor
      }
   }
}
