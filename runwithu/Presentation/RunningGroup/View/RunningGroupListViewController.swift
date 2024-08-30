//
//  RunningGroupListViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import RxSwift
import RxCocoa

final class RunningGroupListViewController: BaseViewController<RunningGroupListView, RunningGroupListViewModel> {
   private let willLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setLogo()
      willLoadInput.onNext(())
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let floatingButtonTapped = PublishSubject<Void>()
      
      let input = RunningGroupListViewModel.Input(
         willLoadInput: willLoadInput,
         floatingButtonTapped: floatingButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      // MARK: bind input
      baseView.floatingButton.rx.tap
         .bind(to: floatingButtonTapped)
         .disposed(by: disposeBag)
      
      baseView.userCreateButton.rx.tap
         .bind(to: floatingButtonTapped)
         .disposed(by: disposeBag)
      
      
      // MARK: bind output
      output.floatingButtonTapped
         .bind(with: self) { vc, _ in
            let targetVC = RunningGroupCreateViewController(
               bv: RunningGroupCreateView(),
               vm: RunningGroupCreateViewModel(
                  disposeBag: DisposeBag(), networkManager: NetworkService.shared
               ),
               db: DisposeBag()
            )
            targetVC.modalPresentationStyle = .fullScreen
            vc.present(targetVC, animated: true)
         }
         .disposed(by: disposeBag)
      
      output.userCreatedGroupOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, userCreated in
            if let first = userCreated.first {
               vc.baseView.bindUserCreateSection(isGroup: true)
               Observable.just([first])
                  .bind(to: vc.baseView.userCreateSectionCollection.rx.items(
                     cellIdentifier: GroupListCollectionCell.id, cellType: GroupListCollectionCell.self)) { row, item, cell in
                        cell.bindView(for: item)
                     }
                     .disposed(by: vc.disposeBag)
            } else {
               vc.baseView.bindUserCreateSection(isGroup: false)
            }
         }
         .disposed(by: disposeBag)
      
      output.userJoinedGroupOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, userJoined in
            if !userJoined.isEmpty {
               vc.baseView.bindUserJoinedSection(isGroup: true)
               Observable.just(userJoined)
                  .bind(to: vc.baseView.userJoinedCollection.rx.items(
                     cellIdentifier: GroupListCollectionCell.id, cellType: GroupListCollectionCell.self)) { row, item, cell in
                        cell.bindView(for: item)
                     }
                     .disposed(by: vc.disposeBag)
            } else {
               vc.baseView.bindUserJoinedSection(isGroup: false)
            }
         }
         .disposed(by: disposeBag)
      
      output.runningGroupOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, runningGroup in
            vc.baseView.runningGroupTable.delegate = nil
            vc.baseView.runningGroupTable.dataSource = nil
            Observable.just(runningGroup)
               .bind(to: vc.baseView.runningGroupTable.rx.items(
                  cellIdentifier: GroupListTableCell.id, cellType: GroupListTableCell.self)
               ) { row, item, cell in
                  cell.bindView(for: item)
               }
               .disposed(by: vc.disposeBag)
            
         }
         .disposed(by: disposeBag)
   }
}
