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
      
      let groupOutButtonTapped = PublishSubject<Void>()
      
      let input = RunnigGroupDetailInfoViewModel.Input(
         didLoadInput: didLoadInput,
         groupOutButtonTapped: groupOutButtonTapped
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
      
      output.isGroupOwnerOutput
         .asDriver(onErrorJustReturn: false)
         .drive(with: self) { vc, isGroupOwner in
            if !isGroupOwner {
               vc.setGroupOutButton("그룹 나가기", color: .red)
               if let rightButton = vc.navigationItem.rightBarButtonItem {
                  rightButton.rx.tap
                     .bind(to: groupOutButtonTapped)
                     .disposed(by: vc.disposeBag)
               }
            }
         }
         .disposed(by: disposeBag)
   }
   
   private func setGroupOutButton(_ title: String, color: UIColor) {
      let groupOutButton = UIBarButtonItem()
      groupOutButton.title = title
      groupOutButton.tintColor = color
      navigationItem.setRightBarButton(groupOutButton, animated: true)
   }
}
