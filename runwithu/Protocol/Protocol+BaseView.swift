//
//  Protocol+BaseView.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit

protocol BaseViewProtocol: UIView {}

protocol BaseViewModelProtocol: AnyObject {
   associatedtype Input
   associatedtype Output
   
   func transform(for input: Input) -> Output
}
