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
   var isThereImages: Bool = false
   
   let scrollView = BaseScrollViewWithCloseButton(
      with: "러닝 일지 작성하기",
      isAdditionButton: true,
      additionButtonTitle: "저장"
   )
   private let requiredRectangle = RectangleView(backColor: .white, radius: 0)
   let titleInput = UITextField()
   let contentInput = UITextView()
   let datePicker = UIDatePicker()
   private let datePickerTitle = BaseLabel(for: "러닝한 날짜를 선택해주세요.", font: .systemFont(ofSize: 14), color: .systemGray3)
   
   private let optionRectangle = RectangleView(backColor: .systemGray6, radius: 12)
   private let optionTitle = BaseLabel(for: "선택 항목", font: .systemFont(ofSize: 16, weight: .semibold))
   private let addPhotoLabel = BaseLabel(for: "러닝 이미지 추가 (최대 5장)", font: .systemFont(ofSize: 14))
   let addPhotoButton = RoundedButtonView("", backColor: .systemGray4, baseColor: .white, radius: 8)
   lazy var addPhotoCollection = UICollectionView(
      frame: .zero, collectionViewLayout: createCollectionLayout())
   let addInvitationPicker = RoundedInputViewWithTitle(label: "일지에 연결할 초대장 선택", placeHolder: "")
   let runningCourse = RoundedInputViewWithTitle(label: "러닝 코스", placeHolder: "이번 러닝의 간략한 코스를 알려주세요!", labelSize: 14)
   let runningHardType = RoundedInputViewWithTitle(label: "러닝 난이도", placeHolder: "이번 러닝의 난이도는 어땠나요?", labelSize: 14)
   
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
               flex.addItem(self.titleInput)
                  .width(100%)
                  .height(44)
                  .marginBottom(8)
               flex.addItem(self.contentInput)
                  .width(100%)
                  .height(200)
               flex.addItem(self.datePickerTitle)
               flex.addItem(self.datePicker)
                  .height(44)
                  .width(200)
                  .marginRight(16)
            }
            .marginBottom(20)
         
         flex.addItem(self.optionRectangle)
            .width(100%)
            .paddingHorizontal(16)
            .direction(.column)
            .define { flex in
               flex.addItem(self.optionTitle)
                  .width(100%)
                  .marginVertical(16)
                              
               flex.addItem(self.addPhotoLabel)
                  .width(100%)
                  .marginBottom(8)
               flex.addItem(self.addPhotoButton)
                  .width(56)
                  .height(40)
               flex.addItem(self.addPhotoCollection)
                  .isIncludedInLayout(self.isThereImages)
                  .width(100%)
                  .height(100)
               
               flex.addItem(self.addInvitationPicker)
                  .width(100%)
                  .marginVertical(8)
               
               flex.addItem(self.runningCourse)
                  .width(100%)
               
               flex.addItem(self.runningHardType)
                  .width(100%)
            }
            .marginBottom(16)
      }
   }
   
   
   override func setUI() {
      super.setUI()
      
      titleInput.placeholder = "러닝 일지 제목을 입력해주세요. :D"
      titleInput.tintColor = .darkGray
      titleInput.font = .systemFont(ofSize: 15)
      titleInput.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 44))
      titleInput.leftViewMode = .always
      contentInput.tintColor = .darkGray
      contentInput.font = .systemFont(ofSize: 15)
      contentInput.backgroundColor = .none
      contentInput.delegate = self
      contentInput.textColor = .systemGray3
      contentInput.text = "이번 러닝은 어땠나요?"
      datePicker.datePickerMode = .date
      datePicker.preferredDatePickerStyle = .compact
      datePicker.locale = Locale(identifier: "ko_KR")
      
      addPhotoButton.setImage(.photoLight, for: .normal)
      addPhotoButton.tintColor = .white
      addPhotoCollection.backgroundColor = .clear
      addPhotoCollection.register(
         BaseWithImageCollectionViewCell.self,
         forCellWithReuseIdentifier: BaseWithImageCollectionViewCell.id)
      
      addInvitationPicker.bindToTitleSize(14.0)
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
   
   func updateCollectionLayout() {
      addPhotoCollection.flex.isIncludedInLayout(isThereImages).markDirty()
      optionRectangle.flex.layout(mode: .adjustHeight)
   }
}

extension RunningEpiloguePostView: UITextViewDelegate {
   func textViewDidBeginEditing(_ textView: UITextView) {
      if textView.textColor == .systemGray3 {
         textView.text = nil
         textView.textColor = .black
      }
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      if textView.text.isEmpty {
         textView.text = "이번 러닝은 어땠나요?"
         textView.textColor = .systemGray3
      }
   }
}
