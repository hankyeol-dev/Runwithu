//
//  Protocol+BaseView.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit

import RxSwift

protocol BaseViewProtocol: UIView {}

extension BaseViewProtocol {
   func displayToast(for message : String, isError: Bool, duration: TimeInterval) {
      DispatchQueue.main.async {
         let toast = UILabel()
         
         toast.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
         toast.backgroundColor = isError ? .systemRed : .systemBlue
         toast.textColor = UIColor.white
         toast.font = .systemFont(ofSize: 14, weight: .semibold)
         toast.textAlignment = .center
         toast.numberOfLines = 0
         toast.text = message
         toast.layer.cornerRadius = 16
         toast.clipsToBounds  =  true
         toast.alpha = 1.0
         
         self.addSubview(toast)
         toast.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(80)
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(80)
            make.height.equalTo(44)
         }
         
         UIView.animate(withDuration: duration, delay: 0.1, options: .curveLinear, animations: {
            toast.alpha = 0.0
         }, completion: { _ in
            toast.removeFromSuperview()
         })
         
      }
   }
}

