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
            vc.presentToSelectedPostView(by: type)
         }
         .disposed(by: disposeBag)
   }
}

extension RunningCommunityViewController {
   private func presentToSelectedPostView(by type: PostsCommunityType) {
      switch type {
      case .epilogue:
         let vc = RunningEpiloguePostViewController(
            bv: RunningEpiloguePostView(),
            vm: RunningEpiloguePostViewModel(
               disposeBag: DisposeBag(), 
               networkManager: NetworkService.shared,
               isInGroupSide: false
            ),
            db: DisposeBag()
         )
         vc.displayViewAsFullScreen(as: .coverVertical)
         present(vc, animated: true)
      case .product_epilogue:
         let vc = ProductEpiloguePostViewController(
            bv: ProductEpiloguePostView(),
            vm: ProductEpiloguePostViewModel(
               disposeBag: DisposeBag(), 
               networkManager: NetworkService.shared,
               isInGroupSide: false),
            db: DisposeBag())
         
         vc.displayViewAsFullScreen(as: .coverVertical)
         present(vc, animated: true)
      case .qna:
         let vc = QnaPostViewController(
            bv: QnaPostView(),
            vm: QnaPostViewModel(
               disposeBag: DisposeBag(),
               networkManager: NetworkService.shared,
               isInGroupSide: false
            ),
            db: DisposeBag())
         vc.displayViewAsFullScreen(as: .coverVertical)
         present(vc, animated: true)
      case .open_self_marathon:
         BaseAlertBuilder(viewController: self)
            .setTitle(for: "🚧 준비중이에요 🚧")
            .setMessage(for: "셀프 마라톤 개최는 곧 오픈 예정이에요 :D")
            .setActions(by: .darkGray, for: "확인")
            .displayAlert()
      }
   }
}
