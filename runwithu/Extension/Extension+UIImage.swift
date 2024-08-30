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
      self.contentMode = .scaleAspectFit
      self.tintColor = tintColor
   }
}


extension UIImage {
   func downscaleTOjpegData(maxBytes: UInt) -> Data? {
      var quality = 1.0
      while quality > 0 {
         guard let jpeg = jpegData(compressionQuality: quality)
         else { return nil }
         if jpeg.count <= maxBytes {
            return jpeg
         }
         quality -= 0.1
      }
      return nil
   }
}
