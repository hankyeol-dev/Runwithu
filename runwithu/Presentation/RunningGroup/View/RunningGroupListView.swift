//
//  RunningGroupListView.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RunningGroupListView: BaseView, BaseViewProtocol {
   private let contentsFlexBox = UIView()
   let floatingButton = PlusButton(backColor: .systemGreen, baseColor: .white)
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(contentsFlexBox)
      [floatingButton].forEach {
         contentsFlexBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin.all(self.pin.safeArea)
      
      floatingButton.pin
         .right(28)
         .bottom(84)
         .size(40)
   }
   
   override func setUI() {
      super.setUI()
      
      contentsFlexBox.backgroundColor = .brown
   }
}
