//
//  CommunityMenuCell.swift
//  runwithu
//
//  Created by 강한결 on 8/28/24.
//

import UIKit

struct CommunityMenuCellItem {
   let menu: PostsCommunityType
   var isSelected: Bool
}

final class CommunityMenuCell: BaseCollectionViewCell {
   let label = BaseLabel(for: "", font: .systemFont(ofSize: 14))
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(label)
   }
   
   override func setLayout() {
      super.setLayout()
      label.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
      }
   }
   
   override func setUI() {
      super.setUI()
      label.textAlignment = .center
      contentView.layer.cornerRadius = 8
      contentView.backgroundColor = .white
   }
   
   func bindView(for item: CommunityMenuCellItem) {
      label.bindText(item.menu.byDetailLabel)
      label.textColor = item.isSelected ? .black : .systemGray2
      label.font = item.isSelected ? .boldSystemFont(ofSize: 14) : .systemFont(ofSize: 14)
      contentView.backgroundColor = item.isSelected ? .systemGray5 : .white
   }
}
