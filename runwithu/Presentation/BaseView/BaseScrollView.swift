//
//  BaseScrollView.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import SnapKit

final class BaseScrollView: BaseView {
   private let scrollView = UIScrollView()
   let contentsView = UIView()
      
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(scrollView)
      scrollView.addSubview(contentsView)
   }
   
   override func setLayout() {
      super.setLayout()
      scrollView.snp.makeConstraints { make in
         make.edges.equalTo(self.safeAreaLayoutGuide)
      }
      contentsView.snp.makeConstraints { make in
         make.width.equalToSuperview()
         make.verticalEdges.equalTo(scrollView)
      }
   }
}
