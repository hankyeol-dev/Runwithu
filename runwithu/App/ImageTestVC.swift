//
//  TestViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit
import Photos
import PhotosUI

import SnapKit
import RxSwift
import RxCocoa

final class ImageTestVC: UIViewController, PHPickerViewControllerDelegate {
   private var images: [Data] = []
   
   func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      dismiss(animated: true)
      guard !results.isEmpty else { return }
      Task {
         await loadImagesFromLibrary(from: results)
      }
   }
   
   let disposeBag = DisposeBag()
   
   let button = RoundedButtonView("이미지", backColor: .black, baseColor: .white, radius: 8)
   let uploadButton = RoundedButtonView("이미지 업로드", backColor: .black, baseColor: .white, radius: 8)
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      view.backgroundColor = .white
      view.addSubviews(button, uploadButton)
      
      button.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
         make.height.equalTo(44)
      }
      uploadButton.snp.makeConstraints { make in
         make.top.equalTo(button.snp.bottom).offset(24)
         make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
         make.height.equalTo(44)
      }
      
      button.rx.tap
         .asDriver()
         .drive(with: self) { vc, _ in
            vc.getPhotoLibraryAuthStatus {
               var config = PHPickerConfiguration()
               config.filter = .images
               config.selection = .ordered
               config.selectionLimit = 3
               
               DispatchQueue.main.async {
                  let imagePicker = PHPickerViewController(configuration: config)
                  imagePicker.delegate = self
                  vc.present(imagePicker, animated: true)
               }
            }
         }
         .disposed(by: disposeBag)
      
      uploadButton.rx.tap
         .bind(with: self) { vc, _ in
//            Task {
//               do {
//                  let result = try await NetworkService.shared.upload(by: PostEndPoint.postImageUpload(input: .init(files: vc.images)), of: ImageUploadOutput.self)
//                  dump(result)
//               } catch {
//                  dump(error)
//               }
//            }
            dump(vc.images)
         }
         .disposed(by: disposeBag)
      
   }
   
   private func getPhotoLibraryAuthStatus(_ permissionHandler: @escaping () -> Void) {
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
   
   private func displayPermissionAlert() {
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
   
   private func loadImagesFromLibrary(from results: [PHPickerResult]) async {
      await withTaskGroup(of: Data?.self) { [weak self] taskGroup in
         guard let self else { return }
         for result in results {
            taskGroup.addTask {
               if let image = await self.loadImage(for: result) {
                  return image
               } else {
                  return nil
               }
            }
         }
         
         for await image in taskGroup {
            if let image {
               self.images.append(image)
            }
         }
      }
   }
   
   func loadImage(for result: PHPickerResult) async -> Data? {
      return await withCheckedContinuation { continuation in
         if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
               if let image = image as? UIImage {
                  let data = image.downscaleTOjpegData(maxBytes: 1_000_000)
                  continuation.resume(returning: data)
               }
            }
         }
      }
   }
}

