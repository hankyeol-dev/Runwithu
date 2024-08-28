//
//  RunningInvitationCreateViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import RxSwift
import RxCocoa

final class RunningInvitationCreateViewController: BaseViewController<RunningInvitationCreateView, RunningInvitationCreateViewModel> {
   var willDisappearHanlder: ((String) -> Void)?
   private let didLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      didLoadInput.onNext(())
   }

   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      let invitationId = viewModel.getInvitationId()
      willDisappearHanlder?(invitationId)
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let inviteButtonTapped = PublishSubject<Void>()
      let inviteTitle = PublishSubject<String>()
      let inviteContent = PublishSubject<String>()
      let inviteDate = PublishSubject<String>()
      let inviteCourse = PublishSubject<String>()
      let inviteTimeTaking = PublishSubject<String>()
      let inviteHardType = PublishSubject<String>()
      let inviteSupplies = PublishSubject<String>()
      let inviteRewards = PublishSubject<String>()
      let createButtonTapped = PublishSubject<Void>()
      
      let input = RunningInvitationCreateViewModel.Input(
         didLoadInput: didLoadInput,
         inviteButtonTapped: inviteButtonTapped,
         inviteTitle: inviteTitle,
         inviteContent: inviteContent,
         inviteDate: inviteDate,
         inviteCourse: inviteCourse,
         inviteTimeTaking: inviteTimeTaking,
         inviteHardType: inviteHardType,
         inviteSupplies: inviteSupplies,
         inviteRewards: inviteRewards,
         createButtonTapped: createButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.headerCloseButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.runningInviteUserPicker
         .inviteButton
         .rx.tap
         .bind(with: self) { _, void in
            inviteButtonTapped.onNext(void)
         }
         .disposed(by: disposeBag)
      
      baseView.runningDatePicker.datePicker
         .rx.date
         .distinctUntilChanged()
         .skip(1)
         .bind(with: self) { vc, date in
            inviteDate.onNext(date.formattedRunningDate())
         }
         .disposed(by: disposeBag)
      
      baseView.runningInvitationContent.inputTextView
         .rx.text.orEmpty
         .distinctUntilChanged()
         .bind(with: self) { vc, content in
            inviteContent.onNext(content)
         }
         .disposed(by: disposeBag)
      
      bindInputViewText(for: baseView.runningInvitationTitle.inputField, to: inviteTitle)
      bindInputViewText(for: baseView.runningCourse.inputField, to: inviteCourse)
      bindInputViewText(for: baseView.runningTimeTaking.inputField, to: inviteTimeTaking)
      bindInputViewText(for: baseView.runningHardType.inputField, to: inviteHardType)
      bindInputViewText(for: baseView.runningSupplies.inputField, to: inviteSupplies)
      bindInputViewText(for: baseView.runningRewards.inputField, to: inviteRewards)
      
      baseView.createButton.rx.tap
         .bind(to: createButtonTapped)
         .disposed(by: disposeBag)
      
      /// bind output
      output.publishedInvitedUsers
         .distinctUntilChanged()
         .bind(to: baseView
            .runningInviteUserPicker
            .inviteCollection.rx.items(
               cellIdentifier: RunningInvitedUserCell.id,
               cellType: RunningInvitedUserCell.self)) { row, item, cell in
                  cell.bindView(with: item)
               }
               .disposed(by: disposeBag)
      
      output.followings
         .asDriver(onErrorJustReturn: nil)
         .drive(with: self) { vc, followings in
            if let followings {
               let bottomSheet = BottomSheetViewController(
                  titleText: "러닝 친구 목록",
                  selectedItems: followings.map {
                     return .init(
                        image: .runnerEmpty, title: $0.nick, isSelected: false)
                  },
                  isScrolled: true,
                  isMultiSelected: true,
                  disposeBag: DisposeBag()
               )
               bottomSheet.didDisappearHandler = {
                  let items = bottomSheet.getSelectedItems()
                  let target = items.filter { $0.isSelected }
                  target.forEach {
                     vc.viewModel.appendOrRemoveFromInvitedUsers(
                        username: $0.title)
                  }
               }
               bottomSheet.modalPresentationStyle = .overFullScreen
               bottomSheet.modalTransitionStyle = .coverVertical
               vc.present(bottomSheet, animated: true)
            }
         }
         .disposed(by: disposeBag)
      
      output.contentText
         .bind(with: self) { vc, content in
            vc.baseView.runningInvitationContent.inputTextView.text = content
            vc.baseView.runningInvitationContent.inputCountLabel.text = "\(content.count) / 100"
         }
         .disposed(by: disposeBag)
      
      bindingInputLabel(
         by: output.titleText,
         for: baseView.runningInvitationTitle)
      
      bindingInputLabel(
         by: output.courseText,
         for: baseView.runningCourse,
         count: 25
      )
      
      bindingInputLabel(
         by: output.supplyText,
         for: baseView.runningSupplies)
      
      bindingInputLabel(
         by: output.rewardsText,
         for: baseView.runningRewards)
      
      output.createResult
         .subscribe(on: MainScheduler.instance)
         .bind(with: self) { vc, result in
            if let error = result.1 {
               vc.baseView.displayToast(for: error, isError: true, duration: 2)
            }
            
            if let success = result.0 {
               DispatchQueue.main.async {
                  vc.dismiss(animated: true)
               }
            }
         }
         .disposed(by: disposeBag)
   }
}

extension RunningInvitationCreateViewController {
   private func bindingInputLabel(
      by output: PublishSubject<String>,
      for inputView: RoundedInputViewWithTitle,
      count: Int = 15
   ) {
      output
         .bind(with: self) { vc, text in
            inputView.inputField.text = text
            inputView.bindToCountLabel(for: "\(text.count) / \(count)")
         }
         .disposed(by: disposeBag)
   }
}
