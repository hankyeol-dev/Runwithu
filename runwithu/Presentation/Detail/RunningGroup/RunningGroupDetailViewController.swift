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
      setGoBackButton(by: .darkGray, imageName: "chevron.left")
      didLoadInput.onNext(())
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let groupJoinButtonTapped = PublishSubject<Void>()
      
      let input = RunningGroupDetailViewModel.Input(
         didLoadInput: didLoadInput,
         groupJoinButtonTapped: groupJoinButtonTapped
      )
      let output = viewModel.transform(for: input)

      /// bind Input

      baseView.groupDetailButton.rx.tap
         .bind(with: self) { vc, _ in
            let targetVC = RunningGroupDetailInfoViewController(
               bv: RunningGroupDetailInfoView(),
               vm: RunnigGroupDetailInfoViewModel(
                  disposeBag: DisposeBag(),
                  networkManager: NetworkService.shared),
               db: DisposeBag()
            )
            let groupPostOutput = vc.viewModel.getGroup()
            targetVC.viewModel.setGroupPosts(by: groupPostOutput)
            vc.navigationController?.pushViewController(targetVC, animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.groupJoinButton.rx.tap
         .bind(with: self) { vc, void in
            let group = vc.viewModel.getGroup()
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "그룹 가입")
               .setMessage(for: "\(group.title) 그룹에 가입합니다.\n-그룹 러닝 난이도\n-러닝 지역\n같은 정보를 잘 확인하셨나요?")
               .setActions(by: .systemRed, for: "취소")
               .setActions(by: .systemGreen, for: "가입할게요") {
                  groupJoinButtonTapped.onNext(void)
               }
               .displayAlert()
         }
         .disposed(by: disposeBag)
      
      /// bind Output
      
      output.didLoadOutput
         .asDriver(onErrorJustReturn: AppEnvironment.drivedPostObject)
         .drive(with: self) { vc, output in
            vc.baseView.bindInfoHeader(by: output)
         }
         .disposed(by: disposeBag)
      
      output.validGroupJoinEmitter
         .asDriver(onErrorJustReturn: false)
         .drive(with: self) { vc, isJoined in
            vc.baseView.updateGroupJoined(by: isJoined)
         }
         .disposed(by: disposeBag)
      
      output.epiloguePostsOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, epilogues in
            vc.baseView.groupEpilogue.bindPostTable(for: epilogues)
         }
         .disposed(by: disposeBag)
      
      output.productPostsOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, products in
            vc.baseView.groupProductEpilogue.bindPostTable(for: products)
         }
         .disposed(by: disposeBag)
      
      output.qnaPostsOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, qnas in
            vc.baseView.groupQna.bindPostTable(for: qnas)
         }
         .disposed(by: disposeBag)
      
      output.errorOutput
         .asDriver(onErrorJustReturn: .dataNotFound)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
            }
            
            if errors == .dataNotFound {
               vc.baseView.displayToast(for: "러닝 그룹(그룹 포스트를)을 찾을 수 없어요.", isError: true, duration: 2.0)
               vc.navigationController?.popViewController(animated: true)
            }
            
            if errors == .invalidResponse {
               let groupName = vc.viewModel.getGroup().title
               BaseAlertBuilder(viewController: vc)
                  .setTitle(for: "그룹에 참여합니다.")
                  .setMessage(for: "\(groupName) 그룹에 참여하는데 문제가 발생했어요.\n잠시 후 다시 시도해주세요.")
                  .setActions(by: .darkGray, for: "확인")
                  .displayAlert()
            }
         }
         .disposed(by: disposeBag)
   }
}
