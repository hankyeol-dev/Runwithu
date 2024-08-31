//
//  InvitationDetailViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import RxSwift
import RxCocoa

final class InvitationDetailViewController: BaseViewController<InvitationDetailView, InvitationDetailViewModel> {
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
      
      setGoBackButton(by: .darkGray, imageName: "chevron.left")
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let dismissButtonTapped = PublishSubject<Void>()
      let joinButtonTapped = PublishSubject<Void>()
      
      let input = InvitationDetailViewModel.Input(
         didLoadInput: didLoadInput,
         dismissButtonTapped: dismissButtonTapped,
         joinButtonTapped: joinButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      baseView.dismissButton.rx.tap
         .bind(with: self, onNext: { _, void in
            dismissButtonTapped.onNext(void)
         })
         .disposed(by: disposeBag)
      
      baseView.joinButton.rx.tap
         .bind(with: self, onNext: { _, void in
            joinButtonTapped.onNext(void)
         })
         .disposed(by: disposeBag)
      
      output.invitationOutput
         .bind(with: self) { vc, invitation in
            vc.baseView.bindView(invitation: invitation)
         }
         .disposed(by: disposeBag)
      
      output.runningInfoOutput
         .bind(with: self) { vc, runningInfo in
            if let runningInfo {
               vc.baseView.bindView(runningInfo: runningInfo)
            }
         }
         .disposed(by: disposeBag)
      
      output.runningEntryOutput
         .bind(with: self) { vc, entries in
            vc.baseView.bindView(entries: entries)
         }
         .disposed(by: disposeBag)
      
      output.joinedOutput
         .bind(with: self) { vc, isJoined in
            vc.baseView.bindView(isJoined: isJoined)
         }
         .disposed(by: disposeBag)
      
      output.errorOutput
         .asDriver(onErrorJustReturn: .dataNotFound)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
            }
            
            if errors == .dataNotFound {
               vc.baseView.displayToast(for: "러닝 초대장을 불러오지 못했어요.", isError: true, duration: 2.0)
            }
         }
         .disposed(by: disposeBag)
   }
}
