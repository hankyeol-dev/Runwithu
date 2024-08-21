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
   private let didLoadInput = PublishSubject<Void>()
   var mode: BottomSheetMode = .singleSelect
   
   enum BottomSheetMode {
      case singleSelect
      case multiSelect
   }
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      didLoadInput.onNext(())
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
   }
   
   override func bindViewAtDidLoad() {
      let tapGesture = UITapGestureRecognizer()
      baseView.back.addGestureRecognizer(tapGesture)
      
      tapGesture.rx.event
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      let singleSelectEmitter = PublishSubject<Int>()
      let multiSelectEmitter = PublishSubject<Int>()
      
      let input = BottomSheetViewModel.Input(
         didLoad: didLoadInput,
         singleSelect: singleSelectEmitter,
         multiSelect: multiSelectEmitter
      )
      let output = viewModel.transform(for: input)
      
      output.didLoad
         .bind(to: baseView.sheetTableView.rx.items(
            cellIdentifier: BottomSheetTableCell.id,
            cellType: BottomSheetTableCell.self)
         ) { row, item, cell in
            cell.bindView(title: item)
         }
         .disposed(by: disposeBag)
      
      output.singleSelect
         .bind(with: self) { _, row in
            print(row)
         }
         .disposed(by: disposeBag)
      
      output.multiSelect
         .bind(with: self) { _, rows in
            dump(rows)
         }
         .disposed(by: disposeBag)
      
      checkMode(
         single: singleSelectEmitter, multi: multiSelectEmitter
      )
   }
   
   private func checkMode(single: PublishSubject<Int>, multi: PublishSubject<Int>) {
      baseView.sheetTableView.rx.itemSelected
         .bind(with: self) { vc, indexPath in
            switch vc.mode {
            case .singleSelect:
               single.onNext(indexPath.row)
               break
            case .multiSelect:
               multi.onNext(indexPath.row)
               break
            }
         }
         .disposed(by: disposeBag)
   }
}
