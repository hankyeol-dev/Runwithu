//
//  BaseLabel.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

final class BaseLabel: UILabel {
   override init(frame: CGRect) {
      super.init(frame: frame)
   }
   
   convenience init(for text: String, font: UIFont, color: UIColor = .black) {
      self.init(frame: .zero)
      self.text = text
      self.font = font
      self.textColor = color
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   func bindText(_ text: String) {
      self.text = text
   }
}
