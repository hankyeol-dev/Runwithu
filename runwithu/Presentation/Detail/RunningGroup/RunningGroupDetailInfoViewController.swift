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
               vc.setGroupOutButton("그룹 나가기", color: .systemRed)
               if let rightButton = vc.navigationItem.rightBarButtonItem {
                  rightButton.rx.tap
                     .bind(with: self, onNext: { vc, void in
                        let groupName = vc.viewModel.getGroupName()
                        BaseAlertBuilder(viewController: vc)
                           .setTitle(for: "그룹을 나갑니다.")
                           .setMessage(for: "\(groupName) 그룹에서 나가는게 맞으신가요?\n작성하신 커뮤니티 포스트는 그룹에서 삭제되지 않습니다.")
                           .setActions(by: .systemRed, for: "취소")
                           .setActions(by: .systemGray, for: "나갈게요") {
                              groupOutButtonTapped.onNext(void)
                           }
                           .displayAlert()
                     })
                     .disposed(by: vc.disposeBag)
               }
            }
         }
         .disposed(by: disposeBag)
      
      output.groupOutOutput
         .asDriver(onErrorJustReturn: false)
         .drive(with: self) { vc, isOut in
            if isOut {
               vc.navigationController?.popViewController(animated: true)
            }
         }
         .disposed(by: disposeBag)
      
      output.errorOutput
         .asDriver(onErrorJustReturn: .invalidResponse)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
            }
            if errors == .invalidResponse {
               let groupName = vc.viewModel.getGroupName()
               BaseAlertBuilder(viewController: vc)
                  .setTitle(for: "그룹 나갑니다.")
                  .setMessage(for: "\(groupName) 그룹에서 나가는데 문제가 발생했어요.\n잠시 후 다시 시도해주세요.")
                  .setActions(by: .darkGray, for: "확인")
                  .displayAlert()
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
