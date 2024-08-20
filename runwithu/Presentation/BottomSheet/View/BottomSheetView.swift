//
//  BottomSheetView.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import SnapKit

final class BottomSheetView: BaseView, BaseViewProtocol {
   let back = {
      let view = UIView()
      view.backgroundColor = .black.withAlphaComponent(0.6)
      return view
   }()
   private let sheetView = {
      let view = UIView()
      view.backgroundColor = .white
      view.layer.cornerRadius = 12
      view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      view.clipsToBounds = true
      return view
   }()
   let sheetTableView = {
      let view = UITableView()
      view.register(BottomSheetTableCell.self, forCellReuseIdentifier: BottomSheetTableCell.id)
      view.rowHeight = 60
      view.separatorStyle = .singleLine
      return view
   }()
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(back)
      addSubview(sheetView)
      sheetView.addSubview(sheetTableView)
   }
   
   override func setLayout() {
      super.setLayout()
      
      back.snp.makeConstraints { make in
         make.edges.equalToSuperview()
      }
      sheetView.snp.makeConstraints { make in
         make.horizontalEdges.bottom.equalToSuperview()
         make.height.equalTo(280)
      }
      sheetTableView.snp.makeConstraints { make in
         make.edges.equalTo(sheetView.safeAreaLayoutGuide).inset(8)
      }
   }
   
   func bindDisplayAnimation() {
      UIView.animate(
         withDuration: 0.1,
         delay: 0,
         options: .curveEaseInOut
      ) {
         self.back.alpha = 0.7
      }
   }
   
   func bindUnDisplayAction() {
      UIView.animate(withDuration: 0.1, delay: 0) {
         self.back.alpha = 0.0
         self.layoutIfNeeded()
      }
   }
}
