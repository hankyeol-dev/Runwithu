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

final class ViewController: UIViewController {
   private let disposeBag = DisposeBag()
   private let button = UIButton()
   private let image = UIImage(systemName: "star.fill")
   private let image2 = UIImage(systemName: "apple.logo")
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white
      title = "hello world"
      
      view.addSubview(button)
      button.configuration = .filled()
      button.configuration?.title = "api shooot"
      button.configuration?.baseBackgroundColor = .black
      button.configuration?.baseForegroundColor = .white
      button.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
         make.height.equalTo(44)
      }
      
      bindButton()
   }
   
   private func bindButton() {
      button.rx.tap
         .debug("button tapped")
         .subscribe(with: self) { owner, _ in
            Task {
               // await owner.testLoginAPI()
               await owner.testPostsInput()
            }
         }
         .disposed(by: disposeBag)
   }
}

extension ViewController {
   private func testLoginAPI() async {
      let loginInput: LoginInput = .init(email: "1@runwithu.com", password: "1")
      
      do {
         let result = try await NetworkService.shared.request(
            by: UserEndPoint.login(input: loginInput),
            of: LoginOutput.self
         )
         
         let accessTokenSaved = await TokenManager.shared.registerAccessToken(by: result.accessToken)
         let refreshTokenSaved = await TokenManager.shared.registerRefreshToken(by: result.refreshToken)
         
         if accessTokenSaved && refreshTokenSaved {
            print("로그인 성공!")
         } else {
            print("로그인에 문제가 있음!")
         }
         
      } catch {
         print(error)
      }
   }
   
   private func testPostsInput() async {
      let runningInfo = RunningInfo(
         date: "2024-08-12",
         course: ["동작역", "이수역", "사당역", "이수역", "동작대교", "반포한강공원"],
         timeTaking: 60,
         hardType: RunningHardType.hard.rawValue,
         supplies: nil,
         reward: nil
      )
      
      if let data = runningInfo.converToJSON(),
         let dataToString = String(data: data, encoding: .utf8) {
         
         let postInput: PostsInput = .init(
            product_id: PostIds.runwithu_community_posts_public.rawValue,
            title: "커뮤니티 글 1",
            content: "커뮤니티 글 1 - 러닝 후기 포스트",
            content1: PostsCommunityType.epilogue.rawValue,
            content2: dataToString,
            content3: nil,
            content4: nil,
            content5: nil,
            files: nil
         )
         
         do {
            let result = try await NetworkService.shared.request(
               by: PostEndPoint.posts(input: postInput),
               of: PostsOutput.self
            )
            
            dump(result)
         } catch {
            dump(error)
         }
         
      }
      
   }
}
