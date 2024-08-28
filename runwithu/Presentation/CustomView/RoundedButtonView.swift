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
   
   convenience init(_ title: String, backColor: UIColor, baseColor: UIColor, radius: CGFloat = 16) {
      self.init(frame: .zero)
      
      setTitle(title, for: .normal)
      setTitleColor(baseColor, for: .normal)
      backgroundColor = backColor
      layer.cornerRadius = radius
   }
}
