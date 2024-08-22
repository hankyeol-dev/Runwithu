//
//  BottomeSheetViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class BottomeSheetViewController: UIViewController {
   private let titleText: String
   private let selectedItems: [String]
   private let isScrolled: Bool
   private let isMultiSelected: Bool
   private let disposeBag: DisposeBag
   
   var didDisappearHandler: (() -> Void)?
   
   private let bottomSheetBox = UIView()
   private let bottomSheetHeaderView = UIView()
   private let bottomSheetTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 16))
   private let bottomSheetHeaderButton = UIButton()
   private let bottomSheetDivider = RectangleView(backColor: .darkGray.withAlphaComponent(0.5), radius: 0)
   private let bottomSheetCommunitySelectionTable = UITableView()
   
   init(
      titleText: String,
      selectedItems: [String],
      isScrolled: Bool,
      isMultiSelected: Bool,
      disposeBag: DisposeBag
   ) {
      self.titleText = titleText
      self.selectedItems = selectedItems
      self.isScrolled = isScrolled
      self.isMultiSelected = isMultiSelected
      self.disposeBag = disposeBag
      super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setSubviews()
      setLayout()
      setUI()
      bindView()
      bindTable()
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      didDisappearHandler?()
   }
   
   private func setSubviews() {
      view.addSubview(bottomSheetBox)
      
      bottomSheetBox.addSubview(bottomSheetHeaderView)
      bottomSheetHeaderView.addSubview(bottomSheetTitle)
      bottomSheetHeaderView.addSubview(bottomSheetHeaderButton)
      bottomSheetBox.addSubview(bottomSheetDivider)
      bottomSheetBox.addSubview(bottomSheetCommunitySelectionTable)
   }
   private func setLayout() {
      bottomSheetBox.snp.makeConstraints { make in
         make.horizontalEdges.bottom.equalToSuperview()
      }
      
      bottomSheetHeaderView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(bottomSheetBox.safeAreaLayoutGuide)
         make.height.equalTo(56)
      }
      bottomSheetTitle.snp.makeConstraints { make in
         make.center.equalToSuperview()
      }
      bottomSheetHeaderButton.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.trailing.equalTo(bottomSheetHeaderView.safeAreaLayoutGuide).inset(16)
         make.width.equalTo(36)
      }
      bottomSheetDivider.snp.makeConstraints { make in
         make.width.equalToSuperview()
         make.top.equalTo(bottomSheetHeaderView.snp.bottom)
         make.height.equalTo(0.5)
      }
      bottomSheetCommunitySelectionTable.snp.makeConstraints { make in
         make.top.equalTo(bottomSheetDivider.snp.bottom)
         make.horizontalEdges.equalTo(bottomSheetBox.safeAreaLayoutGuide)
         make.height.equalTo(240)
         make.bottom.equalTo(bottomSheetBox.safeAreaLayoutGuide).inset(16)
      }
   }
   private func setUI() {
      view.backgroundColor = .black.withAlphaComponent(0.6)
      bottomSheetBox.backgroundColor = .white
      bottomSheetBox.layer.cornerRadius = 16
      bottomSheetBox.clipsToBounds = true
      bottomSheetHeaderView.backgroundColor = .white
      bottomSheetTitle.text = titleText
      bottomSheetTitle.textAlignment = .center
      
      if isMultiSelected {
         bottomSheetHeaderButton.setTitle("선택", for: .normal)
         bottomSheetHeaderButton.setTitleColor(.black, for: .normal)
      } else {
         let buttonImage = UIImage(systemName: "xmark")
         bottomSheetHeaderButton.setImage(buttonImage, for: .normal)
         bottomSheetHeaderButton.tintColor = .black
      }
   }
   
   private func bindView() {
      let tapGesture = UITapGestureRecognizer()
      view.addGestureRecognizer(tapGesture)
      
      tapGesture.rx.event
         .asDriver()
         .drive { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      bottomSheetHeaderButton.rx.tap
         .asDriver()
         .drive(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
   }
   private func bindTable() {
      bottomSheetCommunitySelectionTable.register(
         BottomSheetTableCell.self,
         forCellReuseIdentifier: BottomSheetTableCell.id
      )
      bottomSheetCommunitySelectionTable.rowHeight = 60
      bottomSheetCommunitySelectionTable.isScrollEnabled = isScrolled
      bottomSheetCommunitySelectionTable.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
      
      Observable.just(selectedItems)
         .bind(to: bottomSheetCommunitySelectionTable.rx.items(
            cellIdentifier: BottomSheetTableCell.id,
            cellType: BottomSheetTableCell.self)) { row, item, cell in
               cell.bindView(title: item)
            }
            .disposed(by: disposeBag)
   }
}