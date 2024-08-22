//
//  ViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import PinLayout

final class ViewController: UIViewController {
   private let disposeBag = DisposeBag()
   private let floatButton = {
      let button = UIButton()
      var config = UIButton.Configuration.filled()
      config.image = UIImage(systemName: "plus")
      config.cornerStyle = .capsule
      config.baseBackgroundColor = .systemBlue
      button.configuration = config
      return button
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white
      bindButton()
   }
   
   private func bindButton() {
      view.addSubview(floatButton)
      floatButton.pin
         .right(28)
         .bottom(100)
         .width(44)
         .height(44)
   }
}

extension ViewController {
   
}
