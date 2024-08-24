//
//  Extension+UIView.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import UIKit

extension UIView {
   static var id: String {
      return String(describing: self)
   }
   
   func addSubviews(_ views: UIView...) {
      views.forEach {
         self.addSubview($0)
      }
   }
}

extension UIViewController {
   func displayViewAsFullScreen(as style: UIModalTransitionStyle) {
      self.modalPresentationStyle = .overFullScreen
      self.modalTransitionStyle = style
   }
}
