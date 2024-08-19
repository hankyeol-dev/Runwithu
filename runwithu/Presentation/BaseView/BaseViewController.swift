//
//  BaseViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit

import RxSwift

typealias BaseViewController<BV, VM> = BaseVC<BV, VM> where BV: BaseViewProtocol, VM: BaseViewModelProtocol

class BaseVC<BV, VM>: UIViewController {
   
   let baseView: BV
   let viewModel: VM
   let disposeBag: DisposeBag
   
   init(
      bv: BV,
      vm: VM,
      db: DisposeBag
   ) {
      self.baseView = bv
      self.viewModel = vm
      self.disposeBag = db
      super.init(nibName: nil, bundle: nil)
   }
   
   @available(*, unavailable)
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemBackground
      
      bindViewAtDidLoad()
      bindAction()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      bindViewAtWillAppear()
   }
   
   func bindViewAtDidLoad() {}
   func bindViewAtWillAppear() {}
   func bindAction() {}
}

extension BaseVC {
   func setGoBackButton(
      by color: UIColor
   ) {
      let goBackButton = UIBarButtonItem()
      goBackButton.image = UIImage(systemName: "chevron.left")
      goBackButton.tintColor = color
      goBackButton.style = .plain
      
      goBackButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.navigationController?.popViewController(animated: true)
         }
         .disposed(by: disposeBag)
      
      navigationItem.setLeftBarButton(goBackButton, animated: true)
   }
   
   func dismissStack(for vc: UIViewController) {
      let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
      let sceneDelegate = scene?.delegate as? SceneDelegate
      
      let window = sceneDelegate?.window
      
      window?.rootViewController = UINavigationController(rootViewController: vc)
      window?.makeKeyAndVisible()
   }
   
   func displayAlert() { }
}
