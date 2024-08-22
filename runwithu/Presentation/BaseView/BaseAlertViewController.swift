//
//  BaseAlertViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit

import SnapKit
import RxSwift

struct AlertAction{
   var textColor: UIColor?
   var text: String?
   var action: (() -> Void)?
}

final class BaseAlertViewController: UIViewController {
   private let disposeBag = DisposeBag()
   var alertTitle: String?
   var alertMessage: String?
   var alertActions: [AlertAction?] = []
   
   private let alertBox = RectangleView(backColor: .white, radius: 16)
   private let alertTitleView = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let alertMessageView = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   private let alertDividerView = RectangleView(backColor: .systemGray.withAlphaComponent(0.5), radius: 0)
   private let alertVerticalDividerView = RectangleView(backColor: .systemGray.withAlphaComponent(0.5), radius: 0)
   private let alertButtonFirst = UIButton()
   private let alertButtonSecond = UIButton()

   override func viewDidLoad() {
      super.viewDidLoad()
      setSubviews()
      setLayout()
      setUI()
      setButtons()
   }
   
   private func setSubviews() {
      view.addSubview(alertBox)
      [alertTitleView, alertMessageView, alertDividerView, alertButtonFirst, alertButtonSecond, alertVerticalDividerView].forEach {
         alertBox.addSubview($0)
      }
   }
   
   private func setLayout() {
      alertBox.snp.makeConstraints { make in
         make.center.equalToSuperview()
         make.width.equalTo(300)
      }
      alertTitleView.snp.makeConstraints { make in
         make.top.equalToSuperview().offset(24)
         make.centerX.equalToSuperview()
         make.width.equalTo(256)
      }
      alertMessageView.snp.makeConstraints { make in
         make.centerX.equalToSuperview()
         make.top.equalTo(alertTitleView.snp.bottom).offset(16)
         make.width.equalTo(256)
      }
      alertDividerView.snp.makeConstraints { make in
         make.width.centerX.equalToSuperview()
         make.height.equalTo(0.5)
         make.top.equalTo(alertMessageView.snp.bottom).offset(30)
      }
   }
   
   private func setUI() {
      view.backgroundColor = .black.withAlphaComponent(0.6)
      
      alertBox.backgroundColor = .systemGray5
      alertTitleView.text = alertTitle
      alertTitleView.textAlignment = .center
      alertMessageView.text = alertMessage
      alertMessageView.textAlignment = .center
      alertMessageView.numberOfLines = 0
      alertButtonFirst.titleLabel?.textAlignment = .center
      alertButtonSecond.titleLabel?.textAlignment = .center
   }
   
   private func setButtons() {
      switch alertActions.count {
      case 1:
         setSingleButton()
      case 2:
         setCoupleButton()
      default:
         break
      }
   }
   
   private func setSingleButton() {
      alertButtonFirst.snp.makeConstraints { make in
         make.width.centerX.equalToSuperview()
         make.height.equalTo(48)
         make.top.equalTo(alertDividerView.snp.bottom)
         make.bottom.equalToSuperview()
      }
      alertButtonFirst.setTitle(alertActions[0]?.text, for: .normal)
      alertButtonFirst.titleLabel?.textColor = alertActions[0]?.textColor
      if let firstAction = alertActions[0] {
         alertButtonFirst.setTitle(firstAction.text, for: .normal)
         alertButtonFirst.setTitleColor(firstAction.textColor, for: .normal)
      }
      alertButtonFirst.rx.tap
         .bind(with: self) { vc, _ in
            if let firstAction = vc.alertActions[0] {
               vc.dismiss(animated: true)
               firstAction.action?()
            }
         }
         .disposed(by: disposeBag)
   }
   
   private func setCoupleButton() {
      alertButtonFirst.snp.makeConstraints { make in
         make.width.equalTo(148)
         make.height.equalTo(48)
         make.leading.bottom.equalToSuperview()
         make.top.equalTo(alertDividerView.snp.bottom)
      }
      alertVerticalDividerView.snp.makeConstraints { make in
         make.width.equalTo(0.5)
         make.top.equalTo(alertDividerView.snp.bottom)
         make.centerX.bottom.equalToSuperview()
      }
      alertButtonSecond.snp.makeConstraints { make in
         make.width.equalTo(148)
         make.height.equalTo(48)
         make.trailing.bottom.equalToSuperview()
         make.top.equalTo(alertDividerView.snp.bottom)
      }
      
      if let firstAction = alertActions[0] {
         alertButtonFirst.setTitle(firstAction.text, for: .normal)
         alertButtonFirst.setTitleColor(firstAction.textColor, for: .normal)
      }
      
      if let secondAction = alertActions[1] {
         alertButtonSecond.setTitle(secondAction.text, for: .normal)
         alertButtonSecond.setTitleColor(secondAction.textColor, for: .normal)
      }
      
      alertButtonFirst.rx.tap
         .bind(with: self) { vc, _ in
            if let firstAction = vc.alertActions[0] {
               vc.dismiss(animated: true)
               firstAction.action?()
            }
         }
         .disposed(by: disposeBag)
      
      alertButtonSecond.rx.tap
         .bind(with: self) { vc, _ in
            if let secondAction = vc.alertActions[1] {
               vc.dismiss(animated: true)
               secondAction.action?()
            }
         }
         .disposed(by: disposeBag)
   }
}
