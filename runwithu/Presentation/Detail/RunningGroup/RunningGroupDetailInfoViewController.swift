//
//  RunningGroupDetailInfoViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import RxSwift
import RxCocoa

final class RunningGroupDetailInfoViewController: BaseViewController<RunningGroupDetailInfoView, RunnigGroupDetailInfoViewModel> {
   private let didLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      viewModel.getGroupPost()
         .bind(with: self) { vc, posts in
            vc.baseView.bindView(for: posts)
         }
         .disposed(by: disposeBag)
      didLoadInput.onNext(())
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setGoBackButton(by: .darkGray, imageName: "chevron.left")
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let input = RunnigGroupDetailInfoViewModel.Input(
         didLoadInput: didLoadInput
      )
      let output = viewModel.transform(for: input)
      
      output.didLoadEntrys
         .bind(to: baseView.groupEntryTable.rx.items(
            cellIdentifier: RunningGroupEntryCell.id,
            cellType: RunningGroupEntryCell.self)) { row, entry, cell in
               DispatchQueue.main.async {
                  cell.bindView(for: entry)
               }
            }
            .disposed(by: disposeBag)
   }
}
