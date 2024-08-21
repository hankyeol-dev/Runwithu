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

extension BaseViewModelProtocol {
   func validateEmail(for email: String) -> Bool {
      let regex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._%-]+\\.[A-Za-z]{1,64}"
      return email.range(of: regex, options: .regularExpression) != nil
   }
   
   func validatePassword(for password: String) -> Bool {
      return password.count >= 6
   }
   
   func validateNickname(for nickname: String) -> Bool {
      return nickname.count >= 2
   }
   
   func tempLoginAPI() async {
      do {
         let result = try await NetworkService.shared.request(
            by: UserEndPoint.login(input: .init(email: "7@runwithu.com", password: "777777")),
            of: LoginOutput.self
         )
         
         let accessTokenResult = await TokenManager.shared.registerAccessToken(by: result.accessToken)
         let refreshTokenResult = await TokenManager.shared.registerRefreshToken(by: result.refreshToken)
         print(accessTokenResult, refreshTokenResult)
         
      } catch {
         print("로그인 에러임")
      }
   }
}
