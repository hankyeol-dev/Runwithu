//
//  TestViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit
import WebKit

import SnapKit
import iamport_ios
import RxSwift

final class TestViewController: UIViewController {
   private let disposeBag = DisposeBag()
   private var user = ""
   private let marathonProductId = "runwithu_community_posts_marathon"
   private var marathonPostsList = BehaviorSubject<[PostsOutput]>(value: [])
   
   private let headerStack = UIStackView()
   private let yearLabel = BaseLabel(for: "2024년", font: .boldSystemFont(ofSize: 20))
   private let september = BaseLabel(for: "09월", font: .systemFont(ofSize: 15))
   private let october = BaseLabel(for: "10월", font: .systemFont(ofSize: 15))
   private let november = BaseLabel(for: "11월", font: .systemFont(ofSize: 15))
   private let totalSlidebar = RectangleView(backColor: .systemGray6, radius: 1)
   private let menuslidebar = RectangleView(backColor: .systemOrange, radius: 1)
   private let marathonList = UITableView()
   private let webView = WKWebView()
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      let logoImageView = UIImageView.init(image: UIImage.logo)
      logoImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 28)
      logoImageView.contentMode = .scaleAspectFit
      let imageItem = UIBarButtonItem.init(customView: logoImageView)
      navigationItem.leftBarButtonItems = [imageItem]
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white
      view.addSubviews(headerStack, marathonList, totalSlidebar, menuslidebar)
      headerStack.addArrangedSubview(yearLabel)
      headerStack.addArrangedSubview(september)
      headerStack.addArrangedSubview(october)
      headerStack.addArrangedSubview(november)
      headerStack.snp.makeConstraints { make in
         make.top.equalTo(view.safeAreaLayoutGuide)
         make.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
         make.height.equalTo(32)
      }
      menuslidebar.snp.makeConstraints { make in
         make.top.equalTo(headerStack.snp.bottom).offset(8)
         make.leading.equalTo(view.safeAreaLayoutGuide).inset(102)
         make.height.equalTo(2)
         make.width.equalTo(september.snp.width)
      }
      marathonList.snp.makeConstraints { make in
         make.top.equalTo(menuslidebar.snp.bottom).offset(8)
         make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
      }
      
      headerStack.axis = .horizontal
      headerStack.distribution = .fillProportionally
      headerStack.alignment = .bottom
      headerStack.spacing = 20
      
      Task {
         do {
            let username = try await NetworkService.shared.request(
               by: UserEndPoint.readMyProfile, of: ProfileOutput.self).nick
            
            let posts = try await NetworkService.shared.request(
               by: PostEndPoint.getPosts(input: .init(product_id: marathonProductId, limit: 20 , next: nil)),
               of: GetPostsOutput.self).data
            
            let filtered = posts.filter {
               $0.title.contains("[9월]")
            }
            user = username
            marathonPostsList.onNext(filtered)
         } catch {
            dump(error)
         }
      }
      
      bindTableView()
   }
   
   private func bindTableView() {
      marathonList.register(MarathonListCell.self, forCellReuseIdentifier: MarathonListCell.id)
      marathonList.rowHeight = 450
      
      marathonPostsList
         .bind(to: marathonList.rx.items(
            cellIdentifier: MarathonListCell.id, cellType: MarathonListCell.self)) { row, post, cell in
               if row % 2 == 0 {
                  cell.bindView(for: post)
               } else {
                  cell.bindView2(for: post)
               }
               
               if let content3 = post.content3 {
                  cell.registerButton.rx.tap
                     .bind(with: self) { vc, _ in
                        vc.view.addSubview(vc.webView)
                        vc.webView.backgroundColor = .clear
                        vc.webView.snp.makeConstraints { make in
                           make.edges.equalTo(vc.view.safeAreaLayoutGuide)
                        }
                        
                        let payment = IamportPayment(
                           pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                           merchant_uid: "ios_\(AppEnvironment.headerSecretValue)_\(Int(Date().timeIntervalSince1970))",
                           amount: "\(content3)").then { payment in
                              payment.pay_method = PayMethod.card.rawValue
                              payment.name = "\(post.title) 참가신청"
                              payment.buyer_name = vc.user
                              payment.app_scheme = "sesac"
                           }
                        Iamport.shared.paymentWebView(
                           webViewMode: vc.webView,
                           userCode: "imp57573124",
                           payment: payment) { [weak self] response in
                              guard let self else { return }
                              // valid payment biils
                           }
                     }
                     .disposed(by: cell.disposeBag)
               }
            }
            .disposed(by: disposeBag)
   }
}

final class MarathonListCell: BaseTableViewCell {
   let disposeBag = DisposeBag()
   
   private let imageview = UIImageView()
   private let infoBox = RectangleView(backColor: .black, radius: 0)
   private let titleLable = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20), color: .white)
   private let menuStack = UIStackView()
   private let infoLabel1 = BaseLabel(for: "대회 요강", font: .systemFont(ofSize: 15, weight: .light), color: .white)
   private let infoLabel2 = BaseLabel(for: "참가 방법", font: .systemFont(ofSize: 15, weight: .light), color: .white)
   private let infoLabel3 = BaseLabel(for: "이벤트", font: .systemFont(ofSize: 15, weight: .light), color: .white)
   private let infoLabel4 = BaseLabel(for: "기념품 팩", font: .systemFont(ofSize: 15, weight: .light), color: .white)
   private let totalSlidebar = RectangleView(backColor: .systemGray6.withAlphaComponent(0.5), radius: 1)
   private let menuslidebar = RectangleView(backColor: .systemOrange, radius: 1)
   
   private let miniTitle1 = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .medium), color: .systemGray)
   private let miniContent1 = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .medium), color: .white)
   
   private let miniTitle2 = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .medium), color: .systemGray)
   private let miniContent2 = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .medium), color: .white)
   
   let registerButton = RoundedButtonView("참가신청", backColor: .systemOrange, baseColor: .white, radius: 8)
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubviews(imageview, infoBox)
      infoBox.addSubviews(titleLable, menuStack, registerButton, totalSlidebar, menuslidebar, miniTitle1, miniContent1, miniTitle2, miniContent2)
      [infoLabel1, infoLabel2, infoLabel3, infoLabel4].forEach { menuStack.addArrangedSubview($0) }
   }
   
   override func setLayout() {
      super.setLayout()
      imageview.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(240)
      }
      infoBox.snp.makeConstraints { make in
         make.top.equalTo(imageview.snp.bottom).inset(40)
         make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(240)
      }
      titleLable.snp.makeConstraints { make in
         make.top.equalTo(infoBox.safeAreaLayoutGuide).inset(16)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(20)
      }
      menuStack.snp.makeConstraints { make in
         make.top.equalTo(titleLable.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(28)
      }
      totalSlidebar.snp.makeConstraints { make in
         make.top.equalTo(infoLabel1.snp.bottom)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(1.2)
      }
      
      
      miniTitle1.snp.makeConstraints { make in
         make.top.equalTo(menuslidebar.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(20)
      }
      
      miniContent1.snp.makeConstraints { make in
         make.top.equalTo(miniTitle1.snp.bottom).offset(2)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(20)
      }
      
      miniTitle2.snp.makeConstraints { make in
         make.top.equalTo(miniContent1.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(20)
      }
      
      miniContent2.snp.makeConstraints { make in
         make.top.equalTo(miniTitle2.snp.bottom).offset(2)
         make.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(20)
      }
      
      registerButton.snp.makeConstraints { make in
         make.bottom.horizontalEdges.equalTo(infoBox.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(44)
      }
   }
   
   override func setUI() {
      super.setUI()
      imageview.layer.cornerRadius = 12
      imageview.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
      imageview.clipsToBounds = true
      imageview.contentMode = .scaleAspectFill
      
      infoBox.layer.cornerRadius = 12
      infoBox.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
      
      menuStack.axis = .horizontal
      menuStack.distribution = .fillEqually
      [infoLabel1, infoLabel2, infoLabel3, infoLabel4].forEach {
         $0.textAlignment = .center
      }
   }
   
   func bindView(for post: PostsOutput) {
      menuslidebar.snp.makeConstraints { make in
         make.top.equalTo(infoLabel1.snp.bottom)
         make.leading.equalTo(infoBox.safeAreaLayoutGuide).inset(8)
         make.width.equalTo(infoLabel1.snp.width)
         make.height.equalTo(1.2)
      }
      infoLabel1.font = .systemFont(ofSize: 15, weight: .semibold)
      if let first = post.files.first {
         Task {
            await self.getImageFromServer(for: imageview, by: first)
            titleLable.bindText(post.title)
            miniTitle1.bindText("대회 일자")
            miniTitle2.bindText("대회 장소")
            if let content1 = post.content1, let content4 = post.content4 {
               miniContent1.bindText(content1)
               miniContent2.bindText(content4)
            }
         }
      }
   }
   
   func bindView2(for post: PostsOutput) {
      menuslidebar.snp.makeConstraints { make in
         make.top.equalTo(infoLabel1.snp.bottom)
         make.leading.equalTo(infoBox.safeAreaLayoutGuide).inset(94)
         make.width.equalTo(infoLabel2.snp.width)
         make.height.equalTo(1.2)
      }
      infoLabel2.font = .systemFont(ofSize: 15, weight: .semibold)
      if let first = post.files.first {
         Task {
            await self.getImageFromServer(for: imageview, by: first)
            titleLable.bindText(post.title)
            miniTitle1.bindText("대회 코스")
            miniTitle2.bindText("대회 참가 비용")
            if let content2 = post.content2, let content3 = post.content3 {
               miniContent1.bindText(content2)
               miniContent2.bindText("\(Int(content3)?.formatted() ?? "0")원")
            }
         }
      }
   }
}
