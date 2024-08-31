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
   private var selectedImages: [UIImage] = []
   private let selectedImagesForCollection = BehaviorSubject<[UIImage]>(value: [])
   private let didLoadInput = PublishSubject<Void>()
   
   var willDisappearHanlder: ((String) -> Void)?
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      didLoadInput.onNext(())
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      let epilogueId = viewModel.getEpilogueId()
      willDisappearHanlder?(epilogueId)
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
            vc.getPhotoLibraryAuthStatus {
               vc.displayPhotoLibrary(for: 3)
            }
         }
         .disposed(by: disposeBag)
      
      let titleInput = PublishSubject<String>()
      let contentInput = PublishSubject<String>()
      let dateInput = PublishSubject<String>()
      let selectedInvitation = PublishSubject<String>()
      let courseInput = PublishSubject<String>()
      let hardTypeInput = PublishSubject<String>()
      let createButtonTapped = PublishSubject<Void>()
      
      let input = RunningEpiloguePostViewModel.Input(
         didLoadInput: didLoadInput,
         titleInput: titleInput,
         contentInput: contentInput,
         dateInput: dateInput,
         selectedInvitation: selectedInvitation,
         courseInput: courseInput,
         hardTypeInput: hardTypeInput,
         createButtonTapped: createButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      baseView.addInvitationPicker
         .inputField.rx.text.orEmpty
         .distinctUntilChanged()
         .bind(with: self) { vc, text in
            if text != "연결할 초대장이 없습니다." && !text.isEmpty {
               selectedInvitation.onNext(text)
            }
         }
         .disposed(by: disposeBag)
      
      
      bindingTextToEmitter(for: baseView.titleInput.rx.text.orEmpty, emitter: titleInput)
      bindingTextToEmitter(for: baseView.contentInput.rx.text.orEmpty, emitter: contentInput)
      bindingTextToEmitter(for: baseView.runningCourse.inputField.rx.text.orEmpty, emitter: courseInput)
      bindingTextToEmitter(for: baseView.runningHardType.inputField.rx.text.orEmpty, emitter: hardTypeInput)
      
      baseView.datePicker.rx.date
         .bind(with: self) { vc, date in
            dateInput.onNext(date.formattedRunningDate())
         }
         .disposed(by: disposeBag)
      
      baseView.scrollView.headerAdditionButton.rx.tap
         .bind(to: createButtonTapped)
         .disposed(by: disposeBag)
      
      
      output.didLoadInvitations
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, invitations in
            if invitations.isEmpty {
               vc.baseView.addInvitationPicker.inputField.text = "연결할 초대장이 없습니다."
            } else {
               vc.baseView.addInvitationPicker.bindToInputPickerView(for: invitations)
            }
         }
         .disposed(by: disposeBag)
      
      output.errorEmitter
         .asDriver(onErrorJustReturn: "")
         .drive(with: self) { vc, errorMessage in
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "일지 작성에 문제가 있습니다.")
               .setMessage(for: errorMessage)
               .setActions(by: .black, for: "확인")
               .displayAlert()
         }
         .disposed(by: disposeBag)
      
      output.successEmitter
         .asDriver(onErrorJustReturn: "")
         .drive(with: self) { vc, successMessage in
            vc.baseView.displayToast(for: "성공적으로 일지를 작성했습니다.", isError: false, duration: 1)
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
   }
}

// MARK: 이미지 다루기
extension RunningEpiloguePostViewController: PHPickerViewControllerDelegate {
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
                        if vc.selectedImages.count == 0 {
                           vc.baseView.isThereImages = false
                           vc.baseView.updateCollectionLayout()
                        }
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
            if let image, let data = image.downscaleTOjpegData(maxBytes: 1_000_000) {
               self.selectedImages.append(image)
               self.viewModel.selectedImages.append(data)
            }
         }
         self.baseView.isThereImages = true
         self.baseView.updateCollectionLayout()
         self.selectedImagesForCollection.onNext(self.selectedImages)
      }
   }
}
