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
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      didLoadInput.onNext(())
      
      let isUserProfile = viewModel.getUserProfileState()
      if !isUserProfile {
         setGoBackButton(by: .darkGray, imageName: "chevron.left")
      } else {
         setLogo()
      }
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView.consentCollection
         .rx.modelSelected(PostsOutput.self)
         .asDriver()
         .drive(with: self) { vc, invitation in
            let detail = InvitationDetailViewController(
               bv: .init(),
               vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, invitationId: invitation.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.notConsentCollection
         .rx.modelSelected(PostsOutput.self)
         .asDriver()
         .drive(with: self) { vc, invitation in
            let detail = InvitationDetailViewController(
               bv: .init(),
               vm: .init(disposeBag: DisposeBag(), networkManager: NetworkService.shared, invitationId: invitation.post_id),
               db: DisposeBag())
            vc.navigationController?.pushViewController(detail, animated: true)
         }
         .disposed(by: disposeBag)
   }
   
   override func bindViewAtWillAppear() {
      super.bindViewAtWillAppear()

      let createInvitationButtonTapped = PublishSubject<Void>()
      let followButtonTapped = PublishSubject<Void>()
      let logoutButtonTapped = PublishSubject<Void>()
      
      let input = ProfileViewModel.Input(
         didLoad: didLoadInput,
         followButtonTapped: followButtonTapped,
         createInvitationButtonTapped: createInvitationButtonTapped,
         logoutButtonTapped: logoutButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.sendRunningInvitationButton.rx.tap
         .bind(to: createInvitationButtonTapped)
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
      
      baseView.logoutButton.rx.tap
         .bind(with: self) { vc, void in
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "로그아웃")
               .setMessage(for: "정말 로그아웃 하시나요?\n설정해두신 자동 로그인도 해제됩니다.\n우리 꼭 다시 함께 달려요 :D")
               .setActions(by: .systemRed, for: "취소")
               .setActions(by: .black, for: "확인") {
                  logoutButtonTapped.onNext(void)
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
            createInvitationVC.willDisappearHanlder = { invitationId in
               if !invitationId.isEmpty {
                  let invitation = InvitationDetailViewController(
                     bv: InvitationDetailView(),
                     vm: InvitationDetailViewModel(
                        disposeBag: DisposeBag(),
                        networkManager: NetworkService.shared,
                        invitationId: invitationId
                     ),
                     db: DisposeBag())
                  vc.navigationController?.pushViewController(invitation, animated: true)
               }
            }
            vc.present(createInvitationVC, animated: true)
         }
         .disposed(by: disposeBag)
      
      output.notConsentInvitationOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, invitations in
            vc.baseView.notConsentCollection.delegate = nil
            vc.baseView.notConsentCollection.dataSource = nil
            Observable.just(invitations)
               .bind(to: vc.baseView.notConsentCollection.rx.items(
                  cellIdentifier: ProfileInvitationCollectionCell.id,
                  cellType: ProfileInvitationCollectionCell.self)) { row, invitation, cell in
                     if invitations.isEmpty {
                        cell.bindEmptyView()
                     } else {
                        cell.bindView(for: invitation, index: row, totalIndex: invitations.count)
                     }
                  }
                  .disposed(by: vc.disposeBag)
         }
         .disposed(by: disposeBag)
      
      output.consentInvitationOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, invitations in
            vc.baseView.consentCollection.delegate = nil
            vc.baseView.consentCollection.dataSource = nil
            Observable.just(invitations)
               .bind(to: vc.baseView.consentCollection.rx.items(
                  cellIdentifier: ProfileInvitationCollectionCell.id,
                  cellType: ProfileInvitationCollectionCell.self)) { row, invitation, cell in
                     if invitations.isEmpty {
                        print("여기 들어오지 않니?")
                        cell.bindEmptyView()
                     } else {
                        cell.bindView(for: invitation, index: row, totalIndex: invitations.count)
                     }
                  }
                  .disposed(by: vc.disposeBag)
         }
         .disposed(by: disposeBag)
      
      output.errorEmitter
         .asDriver(onErrorJustReturn: .invalidResponse)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
            }
            
            if errors == .invalidResponse {
               vc.baseView.displayToast(for: "알 수 없는 문제가 발생했어요.", isError: true, duration: 1.5)
            }
         }
         .disposed(by: disposeBag)
      
      output.logoutOutput
         .asDriver(onErrorJustReturn: false)
         .drive(with: self) { vc, isLogoutSuccess in
            if isLogoutSuccess {
               vc.dismissStack(for: LoginViewController(
                     bv: LoginView(),
                     vm: LoginViewModel(
                        disposeBag: DisposeBag(),
                        networkManager: NetworkService.shared,
                        tokenManager: TokenManager.shared,
                        userDefaultsManager: UserDefaultsManager.shared
                     ),
                     db: DisposeBag()
                  ))
            } else {
               vc.baseView.displayToast(for: "로그아웃에 뭔가 문제가 있어요.", isError: true, duration: 2.0)
            }
         }
         .disposed(by: disposeBag)
   }

}
