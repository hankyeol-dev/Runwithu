//
//  BottomSheetViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import RxSwift
import RxCocoa

final class BottomSheetViewController: BaseViewController<BottomSheetView, BottomSheetViewModel>  {
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      bindAction()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      baseView.bindDisplayAnimation()
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let tapGesture = UITapGestureRecognizer()
      baseView.back.addGestureRecognizer(tapGesture)
      
      tapGesture.rx.event
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      Observable.just(viewModel.menus)
         .bind(to: baseView.sheetTableView.rx.items(
            cellIdentifier: BottomSheetTableCell.id,
            cellType: BottomSheetTableCell.self)
         ) { row, item, cell in
            cell.bindView(emoji: "🤮", title: item)
         }
         .disposed(by: disposeBag)
   }
}
