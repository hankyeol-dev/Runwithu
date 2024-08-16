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
   private let LoginButton = {
      let view = UIButton()
      view.configuration = .filled()
      view.configuration?.title = "로그인 shoooooot!"
      view.configuration?.baseBackgroundColor = .black
      view.configuration?.baseForegroundColor = .white
      return view
   }()
   private let postButton = {
      let view = UIButton()
      view.configuration = .filled()
      view.configuration?.title = "포스트 shoooooot!"
      view.configuration?.baseBackgroundColor = .black
      view.configuration?.baseForegroundColor = .white
      return view
   }()
   private let getButton = {
      let view = UIButton()
      view.configuration = .filled()
      view.configuration?.title = "get shoooooot!"
      view.configuration?.baseBackgroundColor = .black
      view.configuration?.baseForegroundColor = .white
      return view
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white
      title = "hello world"
      
      view.addSubview(LoginButton)
      view.addSubview(postButton)
      view.addSubview(getButton)
      
      LoginButton.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
         make.height.equalTo(44)
      }
      postButton.snp.makeConstraints { make in
         make.top.equalTo(LoginButton.snp.bottom).offset(30)
         make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
         make.height.equalTo(44)
      }
      getButton.snp.makeConstraints { make in
         make.top.equalTo(postButton.snp.bottom).offset(30)
         make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
         make.height.equalTo(44)
      }
      
      bindButton()
   }
   
   private func bindButton() {
      LoginButton.rx.tap
         .debug("loginButton tapped")
         .bind(with: self) { vc, _ in
            Task {
               await vc.testLoginAPI()
            }
         }
         .disposed(by: disposeBag)
      
      postButton.rx.tap
         .debug("postButton tapped")
         .bind(with: self) { vc, _ in
            Task {
               await vc.testPostAPI()
            }
         }
         .disposed(by: disposeBag)
      
      getButton.rx.tap
         .debug("getButton tapped")
         .bind(with: self) { vc, _ in
            Task {
               await vc.testGetPostAPI()
            }
         }
         .disposed(by: disposeBag)
   }
}

extension ViewController {
   private func testLoginAPI() async {
      do {
         let results = try await NetworkService.shared.request(
            by: UserEndPoint.login(input: .init(email: "2@runwithu.com", password: "2")),
            of: LoginOutput.self
         )
         
         let accessTokenSaved = await TokenManager.shared.registerAccessToken(by: results.accessToken)
         let refreshTokenSaved = await TokenManager.shared.registerRefreshToken(by: results.refreshToken)
         
         if accessTokenSaved && refreshTokenSaved {
            print("로그인 성공!")
         } else {
            print("로그인에 문제가 있음!")
         }
      } catch {
         print("error from login")
         dump(error)
      }
   }
   private func testPostAPI() async {
      do {
         let owner = try await NetworkService.shared.request(
            by: UserEndPoint.readMyProfile,
            of: ProfileOutput.self
         )
         
         let input: CreateInvitationInput = .init(
            title: "초대장을 만들어볼까?",
            content: "초대장 내용은 대충 아무렇게나 적으셈",
            owner: owner.user_id,
            invited: ["", ""], // 여긴 따로 client에서 처리해야함
            runningInfo: .init(
               date: Date().formattedRunningDate(),
               course: nil, timeTaking: 30, hardType: RunningHardType.easy.rawValue, supplies: nil, reward: nil)
         )
         let results = try await NetworkService.shared.request(
            by: PostEndPoint.posts(input: 
                  .init(
                     product_id: input.productId.rawValue,
                     title: input.title,
                     content: input.content,
                     content1: input.owner,
                     content2: input.invited.joined(separator: " "),
                     content3: input.runningInfo.byJsonString ?? "",
                     content4: nil,
                     content5: nil,
                     files: nil
                  )
            ),
            of: PostsOutput.self
         )
         dump(results)
         
      } catch {
         dump(error)
      }
   }
   private func testGetPostAPI() async {
      do {
         let results = try await NetworkService.shared.request(
            by: PostEndPoint.getPosts(
               input: .init(
                  product_id: ProductIds.runwithu_community_posts_public.rawValue,
                  next: nil
               )
            ),
            of: GetPostsOutput.self
         )
         
         dump(results)
      } catch {
         dump(error)
      }
   }
}
