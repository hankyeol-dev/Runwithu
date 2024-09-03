//
//  EpilogueImageCollectionCell.swift
//  runwithu
//
//  Created by 강한결 on 8/27/24.
//

import UIKit

import SnapKit
import RxSwift

final class EpilogueImageCollectionCell: BaseCollectionViewCell {
   let disposeBag = DisposeBag()
   private let image = UIImageView()
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(image)
   }
   
   override func setLayout() {
      super.setLayout()
      image.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
      }
   }
   
   override func setUI() {
      super.setUI()
      contentView.backgroundColor = .systemGray6.withAlphaComponent(0.8)
      image.layer.cornerRadius = 0
      image.contentMode = .scaleToFill
   }
   
   func bindView(for imageURL: String) {
      Task {
         await self.getImageFromServer(for: self.image, by: imageURL)
      }
   }
}
