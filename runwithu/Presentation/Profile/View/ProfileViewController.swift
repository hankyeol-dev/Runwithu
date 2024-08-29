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
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      let isUserProfile = viewModel.getUserProfileState()
      if !isUserProfile {
         setGoBackButton(by: .darkGray, imageName: "chevron.left")
      } else {
         setLogo()
      }
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let createInvitationButtonTapped = PublishSubject<Void>()
      let followButtonTapped = PublishSubject<Void>()
      
      let input = ProfileViewModel.Input(
         didLoad: didLoadInput,
         followButtonTapped: followButtonTapped,
         createInvitationButtonTapped: createInvitationButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.sendRunningInvitationButton.rx.tap
         .bind(with: self) { _, void in
            createInvitationButtonTapped.onNext(void)
         }
         .disposed(by: disposeBag)
      
      baseView.followButton.rx.tap
         .bind(with: self) { vc, _ in
            let followState = vc.viewModel.getIsFollowing()
            let username = vc.viewModel.getUsername()
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: followState ? "팔로잉 취소" : "팔로잉 하기")
               .setMessage(for: followState ? "정말 팔로잉 취소하시겠어요?" : "\(username)님을 팔로잉 하시겠어요?")
               .setActions(by: .systemRed, for: "취소")
               .setActions(by: .black, for: "확인") {
                  followButtonTapped.onNext(())
               }
               .displayAlert()
         }
         .disposed(by: disposeBag)
      
      /// bind output
      output.getProfileEmitter
         .asDriver(onErrorJustReturn: (nil, nil))
         .drive(with: self) { vc, results in
            if let output = results.0 {
               vc.baseView.bindView(for: output)
            }
            
            if let errorMessage = results.1 {
               print(errorMessage)
            }
         }
         .disposed(by: disposeBag)
      
      output.followStateOutput
         .asDriver(onErrorJustReturn: false)
         .drive(with: self) { vc, isFollowingUser in
            vc.baseView.bindView(for: isFollowingUser)
         }
         .disposed(by: disposeBag)
      
      output.filteredPostsOutput
         .asDriver(onErrorJustReturn: [:])
         .drive(with: self) { vc, postsList in
            vc.baseView.bindView(for: postsList)
         }
         .disposed(by: disposeBag)
      
      output.createInvitationButtonTapped
         .bind(with: self) { vc, userInfo in
            let createInvitationVC = RunningInvitationCreateViewController(
               bv: RunningInvitationCreateView(),
               vm: RunningInvitationCreateViewModel(
                  disposeBag: DisposeBag(), networkManager: NetworkService.shared
               ),
               db: DisposeBag()
            )
            createInvitationVC.viewModel.appendOrRemoveFromInvitedUsers(
               userId: userInfo.0,
               username: userInfo.1
            )
            createInvitationVC.modalPresentationStyle = .fullScreen
            createInvitationVC.willDisappearHanlder = { [weak self] invitationId in
               guard let self else { return }
               let invitation = InvitationDetailViewController(
                  bv: InvitationDetailView(),
                  vm: InvitationDetailViewModel(
                     disposeBag: DisposeBag(),
                     networkManager: NetworkService.shared,
                     invitationId: invitationId
                  ),
                  db: DisposeBag())
               self.navigationController?.pushViewController(invitation, animated: true)
            }
            vc.present(createInvitationVC, animated: true)
         }
         .disposed(by: disposeBag)
      
      output.errorEmitter
         .asDriver(onErrorJustReturn: "알 수 없는 에러가 발생했어요.")
         .drive(with: self) { vc, errorMessage in
            vc.baseView.displayToast(for: errorMessage, isError: true, duration: 2.0)
         }
         .disposed(by: disposeBag)
   }
}
