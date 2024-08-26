//
//  RunningCommunityView.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RunningCommunityView: BaseView, BaseViewProtocol {
   private let contentsFlexBox = UIView()
   let communityWriteButton = PlusButton(backColor: .systemOrange, baseColor: .white)
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(contentsFlexBox)
      contentsFlexBox.addSubviews(communityWriteButton)
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin.all(self.pin.safeArea)
      
      communityWriteButton.pin
         .right(20)
         .bottom(80)
         .size(48)
   }
   
   override func setUI() {
      super.setUI()
   }
}
