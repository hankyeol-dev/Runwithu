//
//  RunningCommunityViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class RunningCommunityViewController: BaseViewController<RunningCommunityView, RunningCommunityViewModel> {
   private let didLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      didLoadInput.onNext(())
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setLogo()
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let writeButtonTapped = PublishSubject<Void>()
      let bottomSheetItemTapped = PublishSubject<BottomSheetSelectedItem>()
      let communityTypeSelected = PublishSubject<Int>()
      
      let input = RunningCommunityViewModel.Input(
         didLoadInput: didLoadInput,
         writeButtonTapped: writeButtonTapped,
         bottomSheetItemTapped: bottomSheetItemTapped,
         communityTypeSelected: communityTypeSelected
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.communityWriteButton.rx.tap
         .bind(to: writeButtonTapped)
         .disposed(by: disposeBag)
      
      baseView.menuButtonCollection
         .rx.itemSelected
         .distinctUntilChanged()
         .bind(with: self) { vc, indexPath in
            communityTypeSelected.onNext(indexPath.row)
         }
         .disposed(by: disposeBag)
      
      baseView.qnaPostTable
         .rx.modelSelected(PostsOutput.self)
         .bind(with: self) { vc, item in
            let detail = QnaDetailViewController(
               bv: QnaDetailView(),
               vm: QnaDetailViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared, qnaId: item.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true
            )
         }
         .disposed(by: disposeBag)
      
      baseView.epiloguePostsTable
         .rx.modelSelected(PostsOutput.self)
         .bind(with: self) { vc, post in
            let detail = RunningEpilogueDetailViewController(
               bv: RunningEpilogueDetailView(),
               vm: RunningEpilogueDetailViewModel(
                  disposeBag: DisposeBag(), 
                  networkManager: NetworkService.shared,
                  epilogueId: post.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.productPostsTable
         .rx.modelSelected(PostsOutput.self)
         .bind(with: self) { vc, post in
            let detail = ProducteDetailViewController(
               bv: .init(),
               vm: .init(
                  disposeBag: DisposeBag(),
                  networkManager: NetworkService.shared,
                  detailPost: post),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
         .disposed(by: disposeBag)
      
      /// bind output
      output.communityMenuOutput
         .bind(to: baseView.menuButtonCollection.rx.items(
            cellIdentifier: CommunityMenuCell.id,
            cellType: CommunityMenuCell.self)
         ) { _, item, cell in
            cell.bindView(for: item)
         }
         .disposed(by: disposeBag)
      
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
                  bottomSheetItemTapped.onNext(first)
               }
            }
            vc.present(bottomSheet, animated: true)
         }
         .disposed(by: disposeBag)
      
      output.bottomSheetItemTapped
         .bind(with: self) { vc, type in
            vc.presentToSelectedPostView(by: type)
         }
         .disposed(by: disposeBag)
      
      output.communityPostsOutput
         .asDriver(onErrorJustReturn: (.qnas, []))
         .drive(with: self) { vc, output in
            if output.0 == .qnas {
               vc.baseView.bindQnaView()
               BehaviorSubject.just(output.1)
                  .bind(to: vc.baseView.qnaPostTable.rx.items(
                     cellIdentifier: QnaPostCell.id, cellType: QnaPostCell.self)
                  ) { row, item, cell in
                     cell.bindView(for: item)
                  }
                  .disposed(by: self.disposeBag)
            }
            
            if output.0 == .epilogues {
               vc.baseView.bindEpilogueView()
               
               BehaviorSubject.just(output.1)
                  .bind(to: vc.baseView.epiloguePostsTable.rx.items(
                     cellIdentifier: EpiloguePostCell.id, cellType: EpiloguePostCell.self)
                  ) { row, post, cell in
                     cell.bindView(for: post)                     
                  }
                  .disposed(by: vc.disposeBag)
            }
            
            if output.0 == .product_epilogues {
               vc.baseView.bindRunningProductView()
               
               BehaviorSubject.just(output.1)
                  .bind(to: vc.baseView.productPostsTable.rx.items(
                     cellIdentifier: ProductPostCell.id,
                     cellType: ProductPostCell.self)
                  ) { row, post, cell in
                     cell.bindView(by: post)
                  }
                  .disposed(by: vc.disposeBag)
            }
         }
         .disposed(by: disposeBag)
      
      output.errorOutput
         .bind(with: self) { vc, error in
            if error == .needToLogin {
               vc.dismissStack(for: LoginViewController(
                  bv: LoginView(),
                  vm: LoginViewModel(
                     disposeBag: DisposeBag(),
                     networkManager: NetworkService.shared,
                     tokenManager: TokenManager.shared,
                     userDefaultsManager: UserDefaultsManager.shared),
                  db: DisposeBag())
               )
            }
         }
         .disposed(by: disposeBag)
   }
}

extension RunningCommunityViewController {
   private func presentToSelectedPostView(by type: PostsCommunityType) {
      switch type {
      case .epilogues:
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
         vc.willDisappearHanlder = { epilogueId in
            if !epilogueId.isEmpty {
               let detail = RunningEpilogueDetailViewController(
                  bv: .init(),
                  vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, epilogueId: epilogueId),
                  db: DisposeBag())
               vc.navigationController?.pushViewController(detail, animated: true)
            }
         }
         present(vc, animated: true)
      case .product_epilogues:
         let vc = ProductEpiloguePostViewController(
            bv: ProductEpiloguePostView(),
            vm: ProductEpiloguePostViewModel(
               disposeBag: DisposeBag(),
               networkManager: NetworkService.shared,
               isInGroupSide: false),
            db: DisposeBag())
         vc.displayViewAsFullScreen(as: .coverVertical)
         vc.willDisappearHanlder = { productEpilogue in
            if let productEpilogue {
               let detail = ProducteDetailViewController(
                  bv: .init(),
                  vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, detailPost: productEpilogue),
                  db: DisposeBag())
               vc.navigationController?.pushViewController(detail, animated: true)
            }
         }
         present(vc, animated: true)
      case .qnas:
         let vc = QnaPostViewController(
            bv: QnaPostView(),
            vm: QnaPostViewModel(
               disposeBag: DisposeBag(),
               networkManager: NetworkService.shared,
               isInGroupSide: false
            ),
            db: DisposeBag())
         vc.displayViewAsFullScreen(as: .coverVertical)
         vc.willDisappearHanlder = { [weak self] postId in
            guard let self else { return }
            if !postId.isEmpty {
               let qnaDetailVC = QnaDetailViewController(
                  bv: QnaDetailView(),
                  vm: QnaDetailViewModel(disposeBag: DisposeBag(),
                                         networkManager: NetworkService.shared,
                                         qnaId: postId), db: DisposeBag())
               
               self.navigationController?.pushViewController(qnaDetailVC, animated: true)
            }
         }
         present(vc, animated: true)
      case .open_self_marathons:
         BaseAlertBuilder(viewController: self)
            .setTitle(for: "🚧 준비중이에요 🚧")
            .setMessage(for: "셀프 마라톤 개최는 곧 오픈 예정이에요 :D")
            .setActions(by: .darkGray, for: "확인")
            .displayAlert()
      }
   }
}
