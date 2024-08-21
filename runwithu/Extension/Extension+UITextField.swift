//
//  Extension+UITextField.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit
import SnapKit

extension UITextField {
   func setRightLabelView(with text: String, by width: CGFloat, background: UIColor) {
      let label = UILabel()
      label.text = text
      label.font = .systemFont(ofSize: 14, weight: .semibold)
      label.textAlignment = .center
      label.backgroundColor = background
      label.layer.zPosition = 100
      self.addSubview(label)
      label.snp.makeConstraints { make in
         make.width.equalTo(width)
         make.trailing.verticalEdges.equalTo(self.safeAreaLayoutGuide)
      }
   }
}
