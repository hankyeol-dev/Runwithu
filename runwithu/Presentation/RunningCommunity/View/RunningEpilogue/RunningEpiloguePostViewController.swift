//
//  RunningEpiloguePostViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit
import Photos
import PhotosUI

import RxSwift
import RxCocoa

final class RunningEpiloguePostViewController: BaseViewController<RunningEpiloguePostView, RunningEpiloguePostViewModel> {
   private var collectionImages = BehaviorSubject<[UIImage]>(value: [])
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView.scrollView.headerCloseButton
         .rx.tap
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.addPhotoButton.rx.tap
         .asDriver()
         .drive(with: self) { vc, _ in
            vc.getPhotoLibraryAuthStatus()
         }
         .disposed(by: disposeBag)
   }
}

extension RunningEpiloguePostViewController: PHPickerViewControllerDelegate {
   private func getPhotoLibraryAuthStatus() {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
         guard let self else { return }
         switch status {
         case .notDetermined:
            print("허용 안함")
         case .denied:
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
         case .authorized, .restricted, .limited:
            self.displayPhotoLibrary()
         @unknown default:
            print("error")
         }
      }
   }
   
   private func displayPhotoLibrary() {
      var config = PHPickerConfiguration()
      config.filter = .images
      config.selection = .ordered
      config.selectionLimit = 5
      
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         let imagePicker = PHPickerViewController(configuration: config)
         imagePicker.delegate = self
         self.present(imagePicker, animated: true)
      }
   }
   
   func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      dismiss(animated: true)
         
      guard !results.isEmpty else { return }
      Task {
         await loadImagesFromLibrary(from: results)
         
         baseView.addPhotoCollection.delegate = nil
         baseView.addPhotoCollection.dataSource = nil
         collectionImages
            .bind(to: baseView.addPhotoCollection.rx.items(
               cellIdentifier: BaseWithImageCollectionViewCell.id,
               cellType: BaseWithImageCollectionViewCell.self)) { [weak self] row, item, cell in
                  guard let self else { return }
                  cell.bindImageView(for: item)
                  cell.imageDeleteButton.rx.tap
                     .bind(with: self) { vc, _ in
                        do {
                           var items = try self.collectionImages.value()
                           if let index = items.firstIndex(of: item) {
                              items.remove(at: index)
                              self.collectionImages.onNext(items)
                           }
                        } catch {
                           self.baseView.displayToast(
                              for: "선택하신 사진을 삭제할 수 없어요 :(",
                              isError: true,
                              duration: 1
                           )
                        }
                     }
                     .disposed(by: self.disposeBag)
                  
               }
               .disposed(by: disposeBag)
      }
   }
   
   private func loadImagesFromLibrary(from results: [PHPickerResult]) async {
      await withTaskGroup(of: UIImage?.self) { taskGroup in
         for result in results {
            taskGroup.addTask {
               if let image = await self.loadImage(for: result) {
                  return image
               } else {
                  return nil
               }
            }
         }
         
         var selectedImages = [UIImage]()
         for await image in taskGroup {
            if let image {
               selectedImages.append(image)
            }
         }
         
         collectionImages.onNext(selectedImages)
      }
   }
   
   private func loadImage(for result: PHPickerResult) async -> UIImage? {
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
