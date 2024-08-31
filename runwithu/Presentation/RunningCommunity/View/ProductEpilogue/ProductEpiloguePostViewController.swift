//
//  ProductEpiloguePostViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit
import Photos
import PhotosUI

import RxSwift
import RxCocoa

final class ProductEpiloguePostViewController: BaseViewController<ProductEpiloguePostView, ProductEpiloguePostViewModel> {
   private var selectedImages: [UIImage] = []
   private let selectedImagesForCollection = BehaviorSubject<[UIImage]>(value: [])
   
   var willDisappearHanlder: ((PostsOutput?) -> Void)?
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      let productEpilogue = viewModel.getProductEpilogue()
      willDisappearHanlder?(productEpilogue)
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView.scrollView.headerCloseButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.addPhotoButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.getPhotoLibraryAuthStatus {
               vc.displayPhotoLibrary(for: 3)
            }
         }
         .disposed(by: disposeBag)
      
      let brandPickerInput = PublishSubject<String>()
      let productTypePickerInput = PublishSubject<String>()
      let titleInput = PublishSubject<String>()
      let contentInput = PublishSubject<String>()
      let ratingInput = PublishSubject<String>()
      let purchaseLinkInput = PublishSubject<String>()
      let createButtonTapped = PublishSubject<Void>()
      
      let input = ProductEpiloguePostViewModel.Input(
         brandPickerInput: brandPickerInput,
         productTypeInput: productTypePickerInput,
         titleInput: titleInput,
         contentInput: contentInput,
         ratingInput: ratingInput,
         purchaseLinkInput: purchaseLinkInput,
         createButtonTapped: createButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      bindingTextToEmitter(
         for: baseView.brandPicker.inputField.rx.text.orEmpty,
         emitter: brandPickerInput)
      bindingTextToEmitter(
         for: baseView.productTypePicker.inputField.rx.text.orEmpty,
         emitter: productTypePickerInput)
      bindingTextToEmitter(
         for: baseView.titleInput.rx.text.orEmpty,
         emitter: titleInput)
      bindingTextToEmitter(
         for: baseView.contentInput.rx.text.orEmpty,
         emitter: contentInput)
      bindingTextToEmitter(
         for: baseView.ratingPicker.inputField.rx.text.orEmpty,
         emitter: ratingInput)
      bindingTextToEmitter(
         for: baseView.purchaseLinkInput.inputField.rx.text.orEmpty,
         emitter: purchaseLinkInput)
      
      baseView.scrollView.headerAdditionButton
         .rx.tap
         .bind(to: createButtonTapped)
         .disposed(by: disposeBag)
      
      /// binding output
      output.successEmitter
         .bind(with: self) { vc, successMessage in
            print(successMessage)
         }
         .disposed(by: disposeBag)
      
      output.errorEmitter
         .asDriver(onErrorJustReturn: "")
         .drive(with: self) { vc, errorMessage in
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "포스트 작성에 문제가 있어요.")
               .setMessage(for: errorMessage)
               .setActions(by: .black, for: "확인")
               .displayAlert()
         }
         .disposed(by: disposeBag)
   }
}

extension ProductEpiloguePostViewController: PHPickerViewControllerDelegate {
   func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      dismiss(animated: true)
      
      guard !results.isEmpty else { return }
      Task {
         await loadImagesFromLibrary(from: results)
         
         baseView.addPhotoCollection.delegate = nil
         baseView.addPhotoCollection.dataSource = nil

         selectedImagesForCollection
            .bind(to: baseView.addPhotoCollection.rx.items(
               cellIdentifier: BaseWithImageCollectionViewCell.id,
               cellType: BaseWithImageCollectionViewCell.self)
            ) { [weak self] row, item, cell in
               guard let self else { return }
               cell.bindImageView(for: item)
               cell.imageDeleteButton.rx.tap
                  .bind(with: self) { vc, _ in
                     if let index = vc.selectedImages.firstIndex(of: item) {
                        vc.selectedImages.remove(at: index)
                        vc.viewModel.selectedImages.remove(at: index)
                        vc.selectedImagesForCollection.onNext(vc.selectedImages)
                     }
                  }
                  .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
      }
   }
   
   func displayPhotoLibrary(for selectionLimit: Int) {
      var config = PHPickerConfiguration()
      config.filter = .images
      config.selection = .ordered
      config.selectionLimit = selectionLimit
      
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         let imagePicker = PHPickerViewController(configuration: config)
         imagePicker.delegate = self
         self.present(imagePicker, animated: true)
      }
   }
   
   private func loadImagesFromLibrary(from results: [PHPickerResult]) async {
      await withTaskGroup(of: UIImage?.self) { [weak self] taskGroup in
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
            if let image, let data = image.pngData() {
               self.selectedImages.append(image)
               self.viewModel.selectedImages.append(data)
            }
         }
         self.selectedImagesForCollection.onNext(self.selectedImages)
      }
   }
}
