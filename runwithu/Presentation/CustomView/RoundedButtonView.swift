//
//  RoundedButtonView.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

final class RoundedButtonView: UIButton {
   
   override init(frame: CGRect) {
      super.init(frame: frame)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   convenience init(_ title: String, backColor: UIColor, baseColor: UIColor) {
      self.init(frame: .zero)
      
      configuration = .filled()
      configuration?.title = title
      configuration?.baseBackgroundColor = backColor
      configuration?.baseForegroundColor = baseColor
   }
   
   func changeAttributes(
      title: String? = nil,
      backColor: UIColor? = nil,
      baseColor: UIColor? = nil
   ) {
      if let title {
         configuration?.title = title
      }
      
      if let backColor {
         configuration?.baseBackgroundColor = backColor
      }
      
      if let baseColor {
         configuration?.baseForegroundColor = baseColor
      }
   }
}
