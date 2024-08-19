//
//  LoginViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

import PinLayout
import FlexLayout

import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController<LoginView, LoginViewModel> {
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView.joinButton.rx
         .tap
         .bind(with: self) { vc, _ in
            let targetVC = JoinViewController(bv: JoinView(), vm: JoinViewModel(), db: DisposeBag())
            vc.navigationController?.pushViewController(targetVC, animated: true)
         }
         .disposed(by: disposeBag)
   }
   
}
