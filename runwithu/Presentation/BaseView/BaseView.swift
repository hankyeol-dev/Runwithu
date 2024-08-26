//
//  BaseView.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

class BaseView: UIView {
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      setSubviews()
      setLayout()
      setUI()
   }
   
   @available(*, unavailable)
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   func setSubviews() {}
   func setLayout() {}
   func setUI() {}
}
