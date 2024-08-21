//
//  ProfileViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import RxSwift
import RxCocoa

final class ProfileViewController: BaseViewController<ProfileView, ProfileViewModel> {
   
   private let didLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      baseView.bindViewState(for: viewModel.getUserProfileState())
      didLoadInput.onNext(())
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let createInvitationButtonTapped = PublishSubject<Void>()
      
      let input = ProfileViewModel.Input(
         didLoad: didLoadInput,
         createInvitationButtonTapped: createInvitationButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.sendRunningInvitationButton.rx.tap
         .bind(with: self) { _, void in
            createInvitationButtonTapped.onNext(void)
         }
         .disposed(by: disposeBag)
      
      
      /// bind output
      output.getProfileEmitter
         .bind(with: self) { vc, results in
            if let output = results.0 {
//               dump(output)
               print("조회 성공!")
            }
            
            if let errorMessage = results.1 {
               print(errorMessage)
            }
         }
         .disposed(by: disposeBag)
      
      output.createButtonTapped
         .bind(with: self) { vc, username in
            let createInvitationVC = RunningInvitationCreateViewController(
               bv: RunningInvitationCreateView(),
               vm: RunningInvitationCreateViewModel(),
               db: DisposeBag()
            )
            createInvitationVC.viewModel.appendOrRemoveFromInvitedUsers(by: username)
            createInvitationVC.modalPresentationStyle = .fullScreen
            vc.present(createInvitationVC, animated: true)
         }
         .disposed(by: disposeBag)
   }
}
