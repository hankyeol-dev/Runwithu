//
//  PostEndPoint.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

enum PostEndPoint: EndPointProtocol {
   case postImageUpload(input: ImageUploadInput)
   case posts(input: PostsInput)
   case getPost(input: GetPostInput)
   case getPosts(input: GetPostsInput)
   case getPostImage(input: GetPostImageInput)
   case updatePost(input: UpdatePostInput)
   case deletePost(input: GetPostInput)
   case postComment(input: CommentsInput)
   case postLike(input: PostLikeInput)
   
   var isNeedToken: Bool {
      return true
   }
   
   var path: String {
      switch self {
      case let .getPostImage(input):
         return "/\(input.imageURL)"
      default:
         return "/posts"
      }
   }
   
   var endPoint: String {
      switch self {
      case .postImageUpload:
         return "/files"
      case .posts, .getPosts, .getPostImage:
         return ""
      case let .getPost(input):
         return "/\(input.post_id)"
      case let .updatePost(input):
         return "/\(input.post_id)"
      case let .deletePost(input):
         return "/\(input.post_id)"
      case let .postComment(input):
         return "/\(input.post_id)/comments"
      case let .postLike(input):
         return "/\(input.postId)/like"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .postImageUpload, .posts, .postComment, .postLike:
         return .post
      case .getPost, .getPosts, .getPostImage:
         return .get
      case .updatePost:
         return .put
      case .deletePost:
         return .delete
      }
   }
   
   var headers: [String : String]? {
      switch self {
      case let .postImageUpload(input):
         return [
            AppEnvironment.headerContentKey
            : AppEnvironment.headerContentMultiValue + "; boundary=\(input.boundary)"
         ]
      default:
         return [AppEnvironment.headerContentKey: AppEnvironment.headerContentJsonValue]
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      case let .getPosts(input):
         if let next = input.next {
            return [
               URLQueryItem(name: "product_id", value: input.product_id),
               URLQueryItem(name: "limit", value: String(input.limit)),
               URLQueryItem(name: "next", value: next)
            ]
         } else {
            return [
               URLQueryItem(name: "product_id", value: input.product_id),
               URLQueryItem(name: "limit", value: String(input.limit)),
            ]
         }
      default:
         return nil
      }
   }
   
   var body: Data? {
      switch self {
      case let .postImageUpload(input):
         return asMultipartFileDatas(for: input.boundary, key: "files", values: input.files, filename: "postImage")
      case let .posts(input):
         return input.converToJSON()
      case let .updatePost(input):
         return input.updateInput.converToJSON()
      case let .postComment(input):
         return input.comment.converToJSON()
      case let .postLike(input):
         return input.isLike.converToJSON()
      default:
         return nil
      }
   }
}
