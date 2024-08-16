//
//  BaseTextFieldWithLine.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

import SnapKit

final class BaseTextFieldWithLine: UITextField {
   let underline = UIView()
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      addSubview(underline)
      
      underline.snp.makeConstraints {
         $0.horizontalEdges.bottom.equalToSuperview()
         $0.height.equalTo(1)
      }
      
      tintColor = .darkGray
      font = .systemFont(ofSize: 15)
      underline.layer.borderWidth = 1
      underline.layer.borderColor = UIColor.darkGray.cgColor
   }
   
   convenience init(_ placeholder: String, keyboardType: UIKeyboardType = .default) {
      self.init(frame: .zero)
      self.placeholder = placeholder
      self.keyboardType = keyboardType
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}
