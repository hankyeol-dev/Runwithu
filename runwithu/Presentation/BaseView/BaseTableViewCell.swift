//
//  BaseTableViewCell.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import SnapKit

class BaseTableViewCell: UITableViewCell {
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
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
