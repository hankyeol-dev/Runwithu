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
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setLogo()
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let floatingButtonTapped = PublishSubject<Void>()
      
      let input = RunningGroupListViewModel.Input(
         floatingButtonTapped: floatingButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      baseView.floatingButton.rx.tap
         .bind(to: floatingButtonTapped)
         .disposed(by: disposeBag)
      
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
   }
}
