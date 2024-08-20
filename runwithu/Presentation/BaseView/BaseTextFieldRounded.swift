//
//  BaseTextFieldRounded.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

final class BaseTextFieldRounded: UITextField {
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      tintColor = .darkGray
      font = .systemFont(ofSize: 15)
      layer.cornerRadius = 8
      layer.borderWidth = 1
      leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
      leftViewMode = .always
   }
   
   convenience init(
      _ placeholder: String,
      keyboardType: UIKeyboardType = .default,
      borderColor: UIColor = .darkGray
   ) {
      self.init(frame: .zero)
      self.placeholder = placeholder
      self.keyboardType = keyboardType
      self.layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}
