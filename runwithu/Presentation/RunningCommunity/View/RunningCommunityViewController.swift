//
//  RunningCommunityViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import RxSwift
import RxCocoa

final class RunningCommunityViewController: BaseViewController<RunningCommunityView, RunningCommunityViewModel> {
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      title = "런윗유 커뮤니티"
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let writeButtonTapped = PublishSubject<Void>()
      let selectedCommunityType = PublishSubject<BottomSheetSelectedItem>()
      
      let input = RunningCommunityViewModel.Input(
         writeButtonTapped: writeButtonTapped,
         selectedCommunityType: selectedCommunityType
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.communityWriteButton.rx.tap
         .bind(to: writeButtonTapped)
         .disposed(by: disposeBag)
      
      /// bind output
      output.writeButtonTapped
         .bind(with: self) { vc, items in
            let bottomSheet = BottomSheetViewController(
               titleText: "커뮤니티 글 작성",
               selectedItems: items,
               isScrolled: false,
               isMultiSelected: false,
               disposeBag: DisposeBag()
            )
            bottomSheet.displayViewAsFullScreen(as: .coverVertical)
            bottomSheet.didDisappearHandler = {
               let item = bottomSheet.getSelectedItems().filter { $0.isSelected }
               if let first = item.first {
                  selectedCommunityType.onNext(first)
               }
            }
            vc.present(bottomSheet, animated: true)
         }
         .disposed(by: disposeBag)
      
      output.selectedCommunityType
         .bind(with: self) { vc, type in
            vc.pushToPostsViewByCommunityType(by: type)
         }
         .disposed(by: disposeBag)
   }
}

extension RunningCommunityViewController {
   private func pushToPostsViewByCommunityType(by type: PostsCommunityType) {
      switch type {
      case .epilogue:
         let vc = RunningEpiloguePostViewController(
            bv: RunningEpiloguePostView(),
            vm: RunningEpiloguePostViewModel(
               disposeBag: DisposeBag(), networkManager: NetworkService.shared
            ),
            db: DisposeBag()
         )
         vc.displayViewAsFullScreen(as: .coverVertical)
//         UINavigationController(rootViewController: vc)
         present(vc, animated: true)
      case .product_epilogue:
         break
      case .qna:
         break
      case .open_self_marathon:
         break
      }
   }
}
