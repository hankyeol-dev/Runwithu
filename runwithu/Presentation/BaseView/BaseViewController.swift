//
//  BaseViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit
import Photos
import PhotosUI

import RxSwift
import RxCocoa

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
      by color: UIColor,
      imageName: String
   ) {
      let goBackButton = UIBarButtonItem()
      goBackButton.image = UIImage(systemName: imageName)
      goBackButton.tintColor = color
      goBackButton.style = .plain
      
      goBackButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.navigationController?.popViewController(animated: true)
         }
         .disposed(by: disposeBag)
      
      navigationItem.setLeftBarButton(goBackButton, animated: true)
   }
   
   func setDismissButton(
      by color: UIColor,
      imageName: String
   ) {
      let closeButton = UIBarButtonItem()
      closeButton.image = UIImage(systemName: imageName)
      closeButton.tintColor = color
      closeButton.style = .plain
      
      closeButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      navigationItem.setLeftBarButton(closeButton, animated: true)
   }
   
   func dismissStack(for vc: UIViewController) {
      let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
      let sceneDelegate = scene?.delegate as? SceneDelegate
      
      let window = sceneDelegate?.window
      
      window?.rootViewController = UINavigationController(rootViewController: vc)
      window?.makeKeyAndVisible()
   }
   
   func bindInputViewText(
      for field: BaseTextFieldRounded,
      to emitter: PublishSubject<String>
   ) {
      field.rx.text.orEmpty
         .bind(with: self) { vc, text in
            emitter.onNext(text)
         }
         .disposed(by: disposeBag)
   }
   
   func bindingTextToEmitter(
      for event: ControlProperty<String>,
      emitter: PublishSubject<String>
   ) {
      event
         .distinctUntilChanged()
         .bind(to: emitter)
         .disposed(by: disposeBag)
   }
   
   func setLogo() {
      //CGRectMake(-40, 0, 150, 25)
      let logoImageView = UIImageView.init(image: UIImage.logo)
      logoImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 28)
      logoImageView.contentMode = .scaleAspectFit
      let imageItem = UIBarButtonItem.init(customView: logoImageView)
//      let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//      negativeSpacer.width = 10
      navigationItem.leftBarButtonItems = [imageItem]
   }
}

extension BaseViewController {
   
   // MARK: 이미지 다루기
   func getPhotoLibraryAuthStatus(_ permissionHandler: @escaping () -> Void) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
         guard let self else { return }
         switch status {
         case .notDetermined, .denied:
            self.displayPermissionAlert()
         case .authorized, .restricted, .limited:
            permissionHandler()
         @unknown default:
            self.displayPermissionAlert()
         }
      }
   }
   
   func displayPermissionAlert() {
      DispatchQueue.main.async {
         BaseAlertBuilder(viewController: self)
            .setTitle(for: "이미지 접근 허용")
            .setMessage(for: "러너님의 이미지 접근 허용이 필요해요.\n설정으로 이동하시겠어요?")
            .setActions(by: .systemRed, for: "취소")
            .setActions(by: .systemBlue, for: "네 이동할래요") {
               guard
                  let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url)
               else { return }
               
               UIApplication.shared.open(url)
            }
            .displayAlert()
      }
   }
   
   
   func loadImage(for result: PHPickerResult) async -> UIImage? {
      return await withCheckedContinuation { continuation in
         if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
               if let image = image as? UIImage {
                  continuation.resume(returning: image)
               }
            }
         }
      }
   }
}
