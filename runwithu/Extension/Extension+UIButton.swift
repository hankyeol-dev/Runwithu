//
//  Extension+UIButton.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

extension UIButton {
   func closeButton() {
      self.configuration = .borderless()
      self.configuration?.image = UIImage(systemName: "xmark")
      self.configuration?.baseBackgroundColor = .none
      self.configuration?.baseForegroundColor = .darkGray
   }
}
