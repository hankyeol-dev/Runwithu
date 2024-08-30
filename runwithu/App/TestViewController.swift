//
//  TestViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit
import Photos
import PhotosUI

import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

enum SectionItem {
   case head(model: PostsOutput)
   case mid(model: PostsOutput)
   case list(model: PostsOutput)
}

enum SectionModel {
   case head(items: [SectionItem])
   case mid(items: [SectionItem])
   case list(items: [SectionItem])
}

extension SectionModel: SectionModelType {
   typealias Item = SectionItem

   var items: [SectionItem] {
      switch self {
      case let .head(items):
         return items
      case .mid(let items):
         return items
      case .list(let items):
         return items
      }
   }
   
   init(original: Self, items: [SectionItem]) {
      self = original
   }
}

final class TestCollectionViewCell: BaseCollectionViewCell {
   private let backView = RectangleView(backColor: .white, radius: 8)
   private let contentStackView = UIStackView()
   private let titleLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18))
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   private let image = UIImageView()
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(backView)
      backView.addSubviews(contentStackView, image)
      contentStackView.addArrangedSubview(titleLabel)
      contentStackView.addArrangedSubview(contentLabel)
   }
   
   override func setLayout() {
      super.setLayout()
      backView.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
      image.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.size.equalTo(80)
         make.trailing.equalTo(backView.safeAreaLayoutGuide).inset(8)
      }
      contentStackView.snp.makeConstraints { make in
         make.centerY.equalTo(image.snp.centerY)
         make.leading.equalTo(backView.safeAreaLayoutGuide).inset(8)
         make.trailing.equalTo(image.snp.leading).offset(-12)
      }
   }
   
   override func setUI() {
      super.setUI()
      image.image = .runner
      contentStackView.axis = .vertical
      contentStackView.distribution = .fillEqually
      contentStackView.spacing = 8
   }
   
   func bindView(for data: PostsOutput) {
      titleLabel.bindText(data.title)
      contentLabel.bindText(data.content)
   }
}

final class TestcollectionViewCell2: BaseCollectionViewCell {
   private let titleLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18))
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   private let image = UIImageView()
   private let countLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   private let spotLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   private let hardTypeLabel = CapsuledLabel()
   
   
}

final class TestViewController: UIViewController {
   private var userCreateGroups: [PostsOutput] = []
   private var userJoinedGroups: [PostsOutput] = []
   private var groupList: [PostsOutput] = []
   
   
   private let disposeBag = DisposeBag()
   private let button = RoundedButtonView("조회", backColor: .black, baseColor: .white)
   private lazy var collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
   
   let datasource = RxCollectionViewSectionedReloadDataSource<SectionModel>{ data, collectionView, index, item in
      switch data[index] {
      case let .head(model):
         guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TestCollectionViewCell.id,
            for: index) as? TestCollectionViewCell else { return UICollectionViewCell() }
         
         cell.bindView(for: model)
         return cell
         
      case let .mid(model):
         guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TestCollectionViewCell.id,
            for: index) as? TestCollectionViewCell else { return UICollectionViewCell() }
         
         cell.bindView(for: model)
         return cell
      case let .list(model):
         guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TestCollectionViewCell.id,
            for: index) as? TestCollectionViewCell else { return UICollectionViewCell() }
         
         cell.bindView(for: model)
         return cell
      }
   }
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      view.backgroundColor = .white
      view.addSubviews(button, collection)
      
      button.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(44)
      }
      collection.snp.makeConstraints { make in
         make.top.equalTo(button.snp.bottom).offset(12)
         make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
      }
      collection.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: TestCollectionViewCell.id)
     
      
      button.rx.tap
         .debug("너는 되는겨?")
         .asDriver(onErrorJustReturn: ())
         .drive(with: self) { vc, _ in
            Task {
               await vc.getUserCreatePost()
               await vc.getUserJoinedPost()
               await vc.getTotalGroups()
               let userCreateGroupItems: [SectionItem] = vc.userCreateGroups.map {
                  .head(model: $0)
               }
               let userJoinedGroupItems: [SectionItem] = vc.userJoinedGroups.map {
                  .mid(model: $0)
               }
               let groupListItems: [SectionItem] = vc.groupList.map {
                  .list(model: $0)
               }
               
               let collectionObservable = BehaviorSubject<[SectionModel]>(value: [
                  .head(items: userCreateGroupItems),
                  .mid(items: userJoinedGroupItems),
                  .list(items: groupListItems)
               ])
               let items = collectionObservable.asDriver(onErrorJustReturn: [])
               items
                  .debug("captured?")
                  .asDriver(onErrorJustReturn: [])
                  .drive(vc.collection.rx.items(dataSource: vc.datasource))
                  .disposed(by: vc.disposeBag)
            }
         }
         .disposed(by: disposeBag)

   }
   
   
}

extension TestViewController {
   private func createLayout() -> UICollectionViewCompositionalLayout {
      let layout = UICollectionViewCompositionalLayout { section, _ in
         switch section {
         case 0:
            return self.createSingleSection()
         case 1:
            return self.createSingleSection()
         case 2:
            return self.createSingleVerticalSection()
         default:
            return self.createSingleSection()
         }
      }
      
      return layout
   }
   
   private func createSingleSection() -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.3))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous
      
      return section
   }
   
   private func createSingleVerticalSection() -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .none
      
      return section
   }
}

extension TestViewController {
//   private func getPosts() async {
//      await withTaskGroup(of: [PostsOutput].self) { taskGroup in
//         for id in ProductIds.allCases.filter({ $0 == .runwithu_running_group || $0 == .runwithu_running_inviation }) {
//            taskGroup.addTask {
//               do {
//                  let posts = try await NetworkService.shared.request(
//                     by: PostEndPoint.getPosts(input: .init(product_id: id.rawValue, limit: 10000, next: nil)),
//                     of: GetPostsOutput.self).data
//                  
//                   let userId = await UserDefaultsManager.shared.getUserId()
//                  
////                  let filteredByCreatorIsMe = posts.filter { post in
////                     post.creator.user_id == userId
////                  }
////
////                  let filteredByLikedIsMe = posts.filter { post in
////                     post.likes.contains(userId)
////                  }
//                  
//                  let filteredByIsHadJoinedUser = posts.filter { post in
//                     post.likes.count != 0
//                  }
//                  
//                  return filteredByIsHadJoinedUser
//               } catch {
//                  dump(error)
//                  return []
//               }
//            }
//         }
//         
//         for await posts in taskGroup {
//            self.posts.append(posts)
//         }
//      }
//   }
   
   private func getUserCreatePost() async {
      do {
         let result = try await NetworkService.shared.request(
            by: PostEndPoint.getPosts(input: .init(product_id: ProductIds.runwithu_running_group.rawValue,
                                                   limit: 20, next: nil)),
            of: GetPostsOutput.self)
         
         let userId = await UserDefaultsManager.shared.getUserId()
         
         if let first = result.data.filter({ $0.creator.user_id == userId }).first {
            userCreateGroups.append(first)
         }
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         let isAutoLogin = await UserDefaultsManager.shared.getAutoLoginState()
         if isAutoLogin {
            let isSuccess = await UserDefaultsManager.shared.autoLogin()
            if isSuccess {
               await getUserJoinedPost()
            }
         }
      } catch {
         dump(error)
      }
   }
   
   private func getUserJoinedPost() async {
      do {
         let result = try await NetworkService.shared.request(
            by: PostEndPoint.getPosts(input: .init(product_id: ProductIds.runwithu_running_group.rawValue,
                                                   limit: 20, next: nil)),
            of: GetPostsOutput.self)
         
         let userId = await UserDefaultsManager.shared.getUserId()
         
         userJoinedGroups = result.data.filter { $0.likes.contains(userId) }
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         let isAutoLogin = await UserDefaultsManager.shared.getAutoLoginState()
         if isAutoLogin {
            let isSuccess = await UserDefaultsManager.shared.autoLogin()
            if isSuccess {
               await getUserJoinedPost()
            }
         }
      } catch {
         dump(error)
      }
   }
   
   private func getTotalGroups() async {
      do {
         let result = try await NetworkService.shared.request(
            by: PostEndPoint.getPosts(input: .init(product_id: ProductIds.runwithu_running_group.rawValue,
                                                   limit: 20, next: nil)),
            of: GetPostsOutput.self)
         
         groupList = result.data
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         let isAutoLogin = await UserDefaultsManager.shared.getAutoLoginState()
         if isAutoLogin {
            let isSuccess = await UserDefaultsManager.shared.autoLogin()
            if isSuccess {
               await getUserJoinedPost()
            }
         }
      } catch {
         dump(error)
      }
   }
}
