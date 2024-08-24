//
//  BaseScrollViewWithCloseButton.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import PinLayout
import FlexLayout

final class BaseScrollViewWithCloseButton: BaseView {
   private let contentsFlexBox = UIView()
   private let scrollView = UIScrollView()
   private let contentsBox = UIView()
   
   private let headerView = UIView()
   private let headerTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 16))
   let headerCloseButton = UIButton()
   
   var flexHandler: ((Flex) -> Void)?
   
   init(with title: String) {
      super.init(frame: .zero)
      headerTitle.text = title
   }
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(contentsFlexBox)
      contentsFlexBox.addSubviews(headerView, scrollView)
      headerView.addSubviews(headerTitle, headerCloseButton)
      scrollView.addSubview(contentsBox)
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin
         .all(self.pin.safeArea)
      
      headerView.pin
         .top(contentsFlexBox.pin.safeArea)
         .horizontally()
         .height(44)
      headerCloseButton.pin
         .left(headerView.pin.safeArea + 24)
         .vCenter()
         .size(12)
      headerTitle.pin
         .hCenter()
         .height(100%)
         .sizeToFit(.height)
      
      scrollView.pin
         .below(of: headerView)
         .horizontally(contentsFlexBox.pin.safeArea)
         .bottom(contentsFlexBox.pin.safeArea)
      
      contentsBox.pin
         .vertically()
         .horizontally()
      
      contentsBox.flex
         .direction(.column)
         .padding(16)
         .rowGap(12)
         .define { [weak self] flex in
            guard let self else { return }
            self.flexHandler?(flex)
         }.layout(mode: .adjustHeight)
      
      scrollView.contentSize = contentsBox.frame.size
   }
   
   override func setUI() {
      super.setUI()
      headerCloseButton.closeButton()
   }
}
