//
//  RectangleView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RectangleView: BaseView {
   
   override func setSubviews() {
      super.setSubviews()
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
   }
   
   convenience init(backColor: UIColor, radius: CGFloat) {
      self.init(frame: .zero)
      backgroundColor = backColor
      layer.cornerRadius = radius
   }
}
