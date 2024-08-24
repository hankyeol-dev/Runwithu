//
//  RunningEpiloguePostView.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit
import Photos
import PhotosUI

import PinLayout
import FlexLayout
import RxSwift

final class RunningEpiloguePostView: BaseView, BaseViewProtocol {
   private let disposeBag = DisposeBag()
   
   let scrollView = BaseScrollViewWithCloseButton(with: "러닝 일지 작성하기")
   private let requiredRectangle = RectangleView(backColor: .systemGray6, radius: 16)
   private let addPhotoLabel = BaseLabel(for: "러닝 사진 추가 (선택)", font: .systemFont(ofSize: 18))
   let addPhotoButton = RoundedButtonView("", backColor: .systemGray3, baseColor: .white, radius: 12)
   lazy var addPhotoCollection = UICollectionView(
      frame: .zero, collectionViewLayout: createCollectionLayout())
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(scrollView)
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      scrollView.pin.all(self.pin.safeArea)
      
      scrollView.flexHandler = { [weak self] flex in
         guard let self else { return }
         
         flex.addItem(self.requiredRectangle)
            .width(100%)
            .padding(16)
            .direction(.column)
            .gap(8)
            .alignItems(.start)
            .define { flex in
               flex.addItem(self.addPhotoLabel)
                  .width(100%)
               flex.addItem(self.addPhotoButton)
                  .width(60)
                  .height(44)
               flex.addItem(self.addPhotoCollection)
                  .width(100%)
                  .height(100)
            }
      }
   }
   
   
   override func setUI() {
      super.setUI()
      
      addPhotoButton.setImage(.photoLight, for: .normal)
      addPhotoButton.tintColor = .white
      addPhotoCollection.backgroundColor = .clear
      addPhotoCollection.register(
         BaseWithImageCollectionViewCell.self,
         forCellWithReuseIdentifier: BaseWithImageCollectionViewCell.id)
   }
}

extension RunningEpiloguePostView {
   private func createCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous
      section.contentInsets = .init(top: 8.0, leading: 0.0, bottom: 8.0, trailing: 0.0)
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}
