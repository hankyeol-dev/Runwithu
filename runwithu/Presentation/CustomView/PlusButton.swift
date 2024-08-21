//
//  PlusButton.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import RxSwift

final class PlusButton: UIButton {
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      var config = UIButton.Configuration.filled()
      config.image = UIImage(systemName: "plus")
      config.cornerStyle = .capsule
      configuration = config
   }
   
   convenience init(backColor: UIColor, baseColor: UIColor) {
      self.init(frame: .zero)
      
      configuration?.baseBackgroundColor = backColor
      configuration?.baseForegroundColor = baseColor
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}
