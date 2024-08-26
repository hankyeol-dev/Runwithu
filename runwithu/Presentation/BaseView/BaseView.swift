//
//  BaseView.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

class BaseView: UIView {
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      setSubviews()
      setLayout()
      setUI()
   }
   
   @available(*, unavailable)
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   func setSubviews() {}
   func setLayout() {}
   func setUI() {}
}

extension BaseView {
   func getImageFromServer(for imageView: UIImageView, by imageURL: String) async {
      do {
         try await NetworkService.shared.requestImage(by: imageURL) { imageData in
            if let imageData {
               DispatchQueue.main.async {
                  imageView.image = UIImage(data: imageData)
               }
            }
         }
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getImageFromServer(for: imageView, by: imageURL)
      } catch {
         dump(error)
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
}
