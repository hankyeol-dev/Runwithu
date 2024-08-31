//
//  RunningGroupDetailViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import Foundation

import RxSwift
import RxCocoa

// TODO: Group Community List
// TODO: 세부적인 UI 다 다듬어야 함

final class RunningGroupDetailViewController: BaseViewController<RunningGroupDetailView, RunningGroupDetailViewModel> {
   private let didLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      title = ""
      setGoBackButton(by: .darkGray, imageName: "chevron.left")
      didLoadInput.onNext(())
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView.groupDetailButton.rx.tap
         .bind(with: self) { vc, _ in
            let targetVC = RunningGroupDetailInfoViewController(
               bv: RunningGroupDetailInfoView(), 
               vm: RunnigGroupDetailInfoViewModel(
                  disposeBag: DisposeBag(),
                  networkManager: NetworkService.shared),
               db: DisposeBag()
            )
            let groupPostOutput = vc.viewModel.getGroupPost()
            targetVC.viewModel.setGroupPosts(by: groupPostOutput)
            vc.navigationController?.pushViewController(targetVC, animated: true)
         }
         .disposed(by: disposeBag)
      
      let input = RunningGroupDetailViewModel.Input(
         didLoadInput: didLoadInput
      )
      let output = viewModel.transform(for: input)
      
      output.didLoadOutput
         .bind(with: self) { vc, output in
            DispatchQueue.main.async {
               vc.baseView.bindInfoHeader(by: output)               
            }
         }
         .disposed(by: disposeBag)
      
      output.validGroupJoinEmitter
         .bind(with: self) { vc, isJoined in
            vc.baseView.updateGroupJoined(by: isJoined)
         }
         .disposed(by: disposeBag)
      
      output.errorOutput
         .asDriver(onErrorJustReturn: .dataNotFound)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
            }
            
            if errors == .dataNotFound {
               vc.baseView.displayToast(for: "러닝 그룹을 찾을 수 없어요.", isError: true, duration: 2.0)
               vc.navigationController?.popViewController(animated: true)
            }
         }
         .disposed(by: disposeBag)
   }
}
