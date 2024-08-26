//
//  Extension+UIView.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import UIKit

import RxSwift

extension UIView {
   static var id: String {
      return String(describing: self)
   }
   
   func addSubviews(_ views: UIView...) {
      views.forEach {
         self.addSubview($0)
      }
   }
   
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
         DispatchQueue.main.async {
            imageView.image = .userSelected
         }
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

extension UIViewController {
   func displayViewAsFullScreen(as style: UIModalTransitionStyle) {
      self.modalPresentationStyle = .overFullScreen
      self.modalTransitionStyle = style
   }
}
