//
//  ProductEpiloguePostView.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit

import PinLayout
import FlexLayout

final class ProductEpiloguePostView: BaseView, BaseViewProtocol {
   let contentViewPlaceHolder = "후기를 상세하게 남겨주시면\n다른 러너분들에게 큰 도움이 됩니다!"
   
   let scrollView = BaseScrollViewWithCloseButton(
      with: "러닝 용품 후기 작성",
      isAdditionButton: true,
      additionButtonTitle: "저장"
   )
   
   private let requiredRectangle = RectangleView(backColor: .white, radius: 0)
   let brandPicker = RoundedInputViewWithTitle(
      label: "브랜드", placeHolder: "브랜드는?", labelSize: 14)
   let productTypePicker = RoundedInputViewWithTitle(
      label: "러닝 용품 타입", placeHolder: "러닝 용품 종류?", labelSize: 14)
   let titleInput = UITextField()
   let contentInput = UITextView()
   
   private let optionRectangle = RectangleView(backColor: .systemGray6, radius: 12)
   private let optionTitle = BaseLabel(for: "선택 항목", font: .systemFont(ofSize: 16, weight: .semibold))
   private let addPhotoLabel = BaseLabel(for: "러닝 용품 사진 (최대 3장)", font: .systemFont(ofSize: 14))
   let addPhotoButton = RoundedButtonView("", backColor: .systemGray4, baseColor: .white, radius: 8)
   lazy var addPhotoCollection = UICollectionView(
      frame: .zero, collectionViewLayout: createCollectionLayout())
   let ratingPicker = RoundedInputViewWithTitle(label: "나만의 평점", placeHolder: "만족도는?", labelSize: 14)
   let purchaseLinkInput = RoundedInputViewWithTitle(label: "제품 구매 링크를 알려주세요.", placeHolder: "온라인 구매 링크가 있다면 붙여 넣어 주세요.", labelSize: 14)
   
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
            .padding(4)
            .direction(.column)
            .define{ flex in
               flex.addItem(self.brandPicker)
                  .width(100%)
               
               flex.addItem(self.productTypePicker)
                  .width(100%)
               
               flex.addItem(self.titleInput)
                  .width(100%)
                  .height(44)
                  .marginBottom(8)
               
               flex.addItem(self.contentInput)
                  .width(100%)
                  .height(200)
                  .marginBottom(12)
            }
            .marginBottom(20)
         
         flex.addItem(optionRectangle)
            .width(100%)
            .paddingHorizontal(16)
            .direction(.column)
            .define { flex in
               flex.addItem(self.optionTitle)
                  .width(100%)
                  .marginVertical(16)
               
               
               flex.addItem(self.ratingPicker)
                  .width(50%)
               flex.addItem(self.purchaseLinkInput)
                  .width(100%)
               
               flex.addItem(self.addPhotoLabel)
                  .width(100%)
                  .marginBottom(8)
               
               flex.addItem(self.addPhotoButton)
                  .width(56)
                  .height(40)
                  .marginBottom(8)
               
               flex.addItem(self.addPhotoCollection)
                  .width(100%)
                  .height(80)
                  .marginBottom(12)
            }
      }
   }
   
   override func setUI() {
      super.setUI()
            
      titleInput.placeholder = "제품 이름을 비롯한 후기 제목을 남겨주세요. :D"
      titleInput.tintColor = .darkGray
      titleInput.font = .systemFont(ofSize: 15)
      titleInput.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 44))
      titleInput.leftViewMode = .always
      contentInput.tintColor = .darkGray
      contentInput.font = .systemFont(ofSize: 15)
      contentInput.backgroundColor = .none
      contentInput.delegate = self
      contentInput.textColor = .systemGray3
      contentInput.text = contentViewPlaceHolder
      
      brandPicker.bindToInputPickerView(for: RunningProductBrandType.allCases.map { $0.byBrandKoreanName })
      brandPicker.hideStateLabel()
      
      productTypePicker.bindToInputPickerView(for: RunningProductType.allCases.map { $0.byProductTypeName })
      productTypePicker.hideStateLabel()
      
      ratingPicker.bindToInputPickerView(for: (1...5).map { String($0) })
      ratingPicker.hideStateLabel()
      
      addPhotoButton.setImage(.photoLight, for: .normal)
      addPhotoCollection.register(
         BaseWithImageCollectionViewCell.self,
         forCellWithReuseIdentifier: BaseWithImageCollectionViewCell.id)
      addPhotoCollection.backgroundColor = .none
   }
}

extension ProductEpiloguePostView: UITextViewDelegate {
   func textViewDidBeginEditing(_ textView: UITextView) {
      if textView.textColor == .systemGray3 {
         textView.text = nil
         textView.textColor = .black
      }
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      if textView.text.isEmpty {
         textView.text = contentViewPlaceHolder
         textView.textColor = .systemGray3
      }
   }
}

extension ProductEpiloguePostView {
   private func createCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous
      section.contentInsets = .init(top: 8.0, leading: 0.0, bottom: 8.0, trailing: 0.0)
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}
