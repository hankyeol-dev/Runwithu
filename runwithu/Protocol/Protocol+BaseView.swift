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

protocol BaseViewModelProtocol: AnyObject {
   associatedtype Input
   associatedtype Output
   
   var disposeBag: DisposeBag { get }
   var networkManager: NetworkService { get }
   
   func transform(for input: Input) -> Output
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
   
   func trimmingText(for text: String, index: Int) -> String {
      if text.count >= index {
         let index = text.index(text.startIndex, offsetBy: index)
         return String(text[..<index])
      } else {
         return text
      }
   }
   
   func countingText(for text: String, limit: Int) -> String {
      if let count = Int(text), count >= limit {
         return "\(limit - 1)"
      } else {
         return text
      }
   }
   
   func tempLoginAPI() async {
      do {
         let result = try await NetworkService.shared.request(
            by: UserEndPoint.login(input: .init(
               email: AppEnvironment.demoEmail, password: AppEnvironment.demoPassword)),
            of: LoginOutput.self
         )
         
         let accessTokenResult = await TokenManager.shared.registerAccessToken(by: result.accessToken)
         let refreshTokenResult = await TokenManager.shared.registerRefreshToken(by: result.refreshToken)
         print(accessTokenResult, refreshTokenResult)
         
      } catch {
         print("로그인 에러임")
      }
   }
   
   func autoLoginCheck(
      autoLoginSuccessHandler: @escaping (Bool) -> Void,
      autoLoginErrorHandler: @escaping () -> Void
   ) async {
      let isAutoLogin = await UserDefaultsManager.shared.getAutoLoginState()
      
      if isAutoLogin {
         let autoLoginResult = await UserDefaultsManager.shared.autoLogin()
         autoLoginSuccessHandler(autoLoginResult)
      } else {
         autoLoginErrorHandler()
      }
   }
   
   func getEntries(
      from userIds: [String],
      completion: @escaping (BaseProfileType) -> Void
   ) async {
      if !userIds.isEmpty {
         await withTaskGroup(of: BaseProfileType?.self) { [weak self] taskGroup in
            guard let self else { return }
            for userId in userIds {
               taskGroup.addTask {
                  if let entry = await self.getEntry(for: userId) {
                     return entry
                  } else {
                     return nil
                  }
               }
            }
            
            for await entry in taskGroup {
               if let entry {
                  completion(entry)
               }
            }
         }
      }
   }
   
   private func getEntry(for userId: String) async -> BaseProfileType? {
      return await withCheckedContinuation { continuation in
         Task {
            do {
               let result = try await networkManager.request(
                  by: UserEndPoint.readAnotherProfile(input: .init(user_id: userId)),
                  of: BaseProfileType.self)
               continuation.resume(returning: result)
            } catch NetworkErrors.needToRefreshRefreshToken {
               await self.tempLoginAPI()
               continuation.resume(returning: await self.getEntry(for: userId))
            } catch {
               continuation.resume(returning: nil)
            }
         }
      }
   }
}
