//
//  TestViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class TestViewController: UIViewController {
   private let bag = DisposeBag()
   private let button1 = RoundedButtonView("알러트 오픈", backColor: .black, baseColor: .white)
   private let button2 = RoundedButtonView("알러트 오픈", backColor: .black, baseColor: .white)
   
   override func viewDidLoad() {
      super.viewDidLoad()
      setView()
      bindView()
   }
   
   private func setView() {
      view.backgroundColor = .white
      view.addSubview(button1)
      view.addSubview(button2)
      
      button1.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
         make.height.equalTo(44)
      }
      button2.snp.makeConstraints { make in
         make.top.equalTo(button1.snp.bottom).offset(20)
         make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
         make.height.equalTo(44)
      }
   }
   
   private func bindView() {
      button1.rx.tap
         .bind(with: self) { vc, _ in
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "하나는 어떠려나?")
               .setMessage(for: "뭐 어때 똑같이 잘 동작하지")
               .setActions(by: .blue, for: "버튼 이름임") {
                  let targetVC = ProfileViewController(
                     bv: ProfileView(),
                     vm: ProfileViewModel(isUserProfile: true, userId: AppEnvironment.demoUserId),
                     db: DisposeBag()
                  )
                  targetVC.modalPresentationStyle = .fullScreen
                  vc.present(targetVC, animated: true)
               }
               .displayAlert()
         }
         .disposed(by: bag)
      
      button2.rx.tap
         .bind(with: self) { vc, _ in
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "내꺼 테스트")
               .setMessage(for: "내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트내꺼 테스트")
               .setActions(by: .black, for: "내꺼 테스트") {
                  print("내꺼 테스트 button 1")
               }
               .setActions(by: .red, for: "내꺼 테스트2") {
                  print("내꺼 테스트 button 2")
               }
               .displayAlert()
         }
         .disposed(by: bag)
   }
}
