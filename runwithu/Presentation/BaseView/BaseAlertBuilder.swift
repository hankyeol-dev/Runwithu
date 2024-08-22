//
//  BaseAlertBuilder.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit

final class BaseAlertBuilder {
   private let viewController: UIViewController
   private let alertController = BaseAlertViewController()
   
   private var title: String?
   private var message: String?
   private var alertActions: [AlertAction?] = []
   
   init(viewController: UIViewController) {
      self.viewController = viewController
   }
   
   func setTitle(for title: String) -> BaseAlertBuilder {
      self.title = title
      return self
   }
   
   func setMessage(for message: String) -> BaseAlertBuilder {
      self.message = message
      return self
   }
   
   func setActions(
      by color: UIColor,
      for buttonTitle: String,
      action: (() -> Void)? = nil
   ) -> BaseAlertBuilder {
      self.alertActions.append(.init(textColor: color, text: buttonTitle, action: action))
      return self
   }
   
   func displayAlert() {
      alertController.modalPresentationStyle = .overFullScreen
      alertController.modalTransitionStyle = .crossDissolve
      
      alertController.alertTitle = title
      alertController.alertMessage = message
      alertController.alertActions = alertActions
      
      viewController.present(alertController, animated: true)
   }
}
