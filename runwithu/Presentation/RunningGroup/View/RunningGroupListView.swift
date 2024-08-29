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
   private let scrollView = BaseScrollView()
   let floatingButton = PlusButton(backColor: .systemGreen, baseColor: .white)
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubviews(scrollView, floatingButton)
   }
   
   override func setLayout() {
      super.setLayout()
      
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
    
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(64)
      }
      floatingButton.snp.makeConstraints { make in
         make.trailing.equalTo(safeAreaLayoutGuide).inset(24)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(76)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      scrollView.backgroundColor = .black
   }
}
