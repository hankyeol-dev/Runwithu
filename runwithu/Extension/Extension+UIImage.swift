//
//  Extension+UIImage.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

extension UIImageView {
   func forSymbolImageWithTintColor(
      for systemName: String,
      ofSize: CGFloat,
      tintColor: UIColor
   ) {
      let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: ofSize))
      self.image = UIImage(systemName: systemName, withConfiguration: config)
      self.tintColor = tintColor
   }
}
