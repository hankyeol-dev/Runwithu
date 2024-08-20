//
//  RunningGroupPreviewView.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RunningGroupPreviewView: BaseView {
   private let flexBox = UIView()
   
   private let titleView = UIView()
   private let runningEmoji = BaseLabel(for: "🏃🏻", font: .boldSystemFont(ofSize: 20))
   let groupName = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20), color: .white)
   private let groupEntryLimit = StepBar(labelText: "러닝 인원 - ")
   private let groupSpot = StepBar(labelText: "러닝 스팟 - ")
   private let groupHardType = StepBar(labelText: "러닝 난도 - ")
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      [titleView, groupEntryLimit, groupSpot, groupHardType].forEach {
         flexBox.addSubview($0)
      }
      [runningEmoji, groupName].forEach {
         titleView.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      flexBox.pin
         .horizontally(self.pin.safeArea + 16)
         .vertically(self.pin.safeArea + 8)
      
      flexBox.flex
         .direction(.column)
         .define { flex in
            flex.addItem(titleView)
               .width(100%)
               .height(35%)
               .direction(.row)
               .alignItems(.center)
               .justifyContent(.start)
               .define { flex in
                  flex.addItem(runningEmoji)
                     .margin(0, 16, 0, 16)
                  flex.addItem(groupName)
                     .width(100%)
                     .height(100%)
               }
            
            flex.addItem(groupEntryLimit)
            flex.addItem(groupSpot)
            flex.addItem(groupHardType)
         }
      flexBox.flex.layout(mode: .fitContainer)
   }
   
   override func setUI() {
      super.setUI()
      
      flexBox.layer.cornerRadius = 12
      flexBox.layer.masksToBounds = true
      flexBox.backgroundColor = .systemGreen.withAlphaComponent(1.01)
      
      titleView.backgroundColor = .systemGreen
      
      runningEmoji.textAlignment = .center
   }
}

extension RunningGroupPreviewView {
   func bindTitleView(for text: String) {
      groupName.text = text
   }
   
   func bindEntryLimitView(for text: String) {
      groupEntryLimit.additionLabelText(by: text)
   }
   
   func bindSpotView(for text: String) {
      groupSpot.additionLabelText(by: text)
   }
   
   func bindHardTypeView(for text: String) {
      groupHardType.additionLabelText(by: text)
   }
}
