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
      
      let groupCreateButtonTapped = PublishSubject<Void>()
      
      let input = RunningGroupListViewModel.Input(
         willLoadInput: willLoadInput,
         groupCreateButtonTapped: groupCreateButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      // MARK: bind input
      
      baseView.userCreateButton.rx.tap
         .bind(to: groupCreateButtonTapped)
         .disposed(by: disposeBag)
      
      baseView.userCreateSectionCollection
         .rx.modelSelected(PostsOutput.self)
         .asDriver()
         .drive(with: self) { vc, group in
            vc.baseView.userJoinedCollection.delegate = nil
            vc.baseView.userCreateSectionCollection.dataSource = nil
            let detail = RunningGroupDetailViewController(
               bv: .init(),
               vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, groupId: group.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.userJoinedCollection
         .rx.modelSelected(PostsOutput.self)
         .asDriver()
         .drive(with: self) { vc, group in
            let detail = RunningGroupDetailViewController(
               bv: .init(),
               vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, groupId: group.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.runningGroupTable
         .rx.modelSelected(PostsOutput.self)
         .asDriver()
         .drive(with: self) { vc, group in
            let detail = RunningGroupDetailViewController(
               bv: .init(),
               vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, groupId: group.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
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
