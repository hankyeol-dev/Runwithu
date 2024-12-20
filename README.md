# 함께 달려요 RunwithU

**목차**

- [프로젝트 소개](#프로젝트-소개)
- [프로젝트 구현 스택](#프로젝트-아키텍처-및-스택)
- [프로젝트에서 고민한 것](#프로젝트에서-고민한-것들)
  - [1. EndpointProtocol을 통한 네트워크 통신 Router 패턴](#1.-Endpoint-프로토콜을-통한-네트워크-통신-Router-패턴-적용)
  - [2. Swift Concurrency 기반의 비동기 태스크 동시성 관리](#2.-Swift-Concurrency-기반의-비동기-태스크-동시성-관리)
  - [3. Actor 객체를 활용한 JWT 기반 토큰 관리](#3.-Actor-객체를-활용한-JWT-기반-토큰-관리)
- [프로젝트에서 구현한 화면 및 기능](#프로젝트-페이지별-기능)

<br />

## 프로젝트 소개

러닝과 관련된 글을 작성하고, 나만의 러닝 그룹을 만들어 다른 러너들과 소통하며, 함께 달리기 초대장을 보낼 수 있는 러닝 전문 커뮤니티 앱

- 개발 인원: 강한결 (1인 프로젝트)
- 기간 : **2024.08.15 ~ 09.01**
- 최소 지원 버전: iOS 15.0
- 주요 기능
  - 러닝과 관련된 커뮤니티(러닝 일지/용품 후기/QnA) 글을 작성하고 댓글로 소통할 수 있습니다.
  - 나만의 러닝 그룹을 만들고, 러닝 그룹별 커뮤니티를 운영할 수 있습니다.
  - 앱을 이용하는 다른 러너 유저를 팔로우하고, 함께 달리기 초대장을 보낼 수 있습니다.

<br />

## 프로젝트 아키텍처 및 스택

|스택|활용|
|:--:|:-----:|
| **UIKit, PinLayout, Snapkit** | 컴포넌트 및 레이아웃 구현, 앱 라이프사이클 관리 |
| **RxCocoa, RxSwift** | 이벤트 기반 비동기 데이터 스트림 관리 | 
| **Swift Concurrency** | 비동기 태스크(네트워크) 동시성 관리, Token 정보 관리 (actor) |
| **Keychain** | Token 암호화 저장 |
| **iamport SDK** | 결제 영수증 검증 |


<br />

**CompositionalLayout을 적용한 리스트 뷰**
> - UIKit CompositionalLayout을 CollectionView에 적용했습니다. 유저가 작성한 커뮤니티 글과 러닝 그룹 목록을 조회하는 리스트 뷰의 레이아웃을 유연하게 설정할 수 있었습니다.

<br />

**MVVM 기반 Input-Output 패턴**
> - [BaseViewModel 프로토콜](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Protocol/BaseViewModel.swift) 을 채택한 ViewModel이 **모두 동일한 In-Out 패턴을 구축하고, 프로토콜에서 확장된 메서드를 활용하는 구조**를 만들었습니다.
> - ViewModel에 **NestedType으로 Input 구조체를 선언**하여, **View에서 방출되는 이벤트 케이스를 명확하게 구분**할 수 있었습니다.
> - **transform 메서드로 업데이트된 데이터를, RxSwift의 Single, PublishSubject 기반 데이터 스트림으로 만들어, View가 Output 객체를 통해 구독할 수 있는 구조**를 구현했습니다.

<br />

**RxSwift**
> - RxCocoa의 RxRelay로 모든 View 이벤트를 ViewModel Input에 방출시켰습니다. 
> - ViewModel에서 전달된 데이터 스트림을 bind, driver 오퍼레이터로 구독하여 View를 업데이트 했습니다. 

<br />

**Swift Concurrency 기반의 비동기 태스크 및 전역 상태 관리**
> - URLSession 기반의 네트워크 통신을 async throw 함수로 만들어, **API를 활용 로직이 통신 시점을 제어하고, Output과 Error를 명확하게 핸들링 할 수 있게 구현**했습니다. await로 네트워크 통신 완료 시점을 제어하여 토큰 갱신 로직을 자동으로 처리했습니다.
> - **Task로 독립적인 비동기 컨텍스트를 생성**하고, **await로 비동기 태스크의 반환값 및 에러를 핸들링 시점을 제어**했습니다. 이미지 URL 배열이 전달되는 경우, TaskGroup, withContinuation을 활용하여 이미지 로딩 통신을 제어했습니다.
> - **API 호출마다 활용하는 AccessToken을 Data Race 없이 thread-safe하게 접근하고 업데이트 할 수 있도록 Actor를 사용**했습니다. 

<br />

**커스텀 Router 프로토콜을 적용한 API 호출**
> - `Moya`, `Alamofire` 라이브러리의 TargetType, URLRequestConvertible 프로토콜을 참고하여, API **엔드포인트마다 필요한 URLRequest 객체를 맵핑해주는 커스텀 [Routing 프로토콜](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Protocol/EndPoint.swift)** 을 구현했습니다.
> - API 호출마다 필요한 [DTO(request, response)](https://github.com/hankyeol-dev/Runwithu/tree/main/runwithu/Model/DTO) 타입 객체를 구조화했습니다. Router에서 엔드포인트가 전달해야 하는 InputType을 명시하고, 통신 결과로 반환받을 OutputType을 구체화 했습니다.
> - 이미지/파일 업로드를 위해 **multipart/form-data 형식의 httpBody를 맵핑해주는 메서드를 구현**했습니다.
> - 라우터에서 httpHeader에 갱신된 AccessToken을 반영하는 로직을 적용했습니다. 

<br />

<img width="100%" alt="스크린샷 2024-10-18 오전 10 55 52" src="https://github.com/user-attachments/assets/1301cd07-3643-41c8-9fe5-d6a04ede7dbe">

> 프로젝트 데이터 및 의존성 구조

<br />

## 프로젝트에서 고민한 것들

### 1. Endpoint 프로토콜을 통한 네트워크 통신 Router 패턴 적용

> 관련 코드: [EndpointProtocol](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Protocol/EndPoint.swift), [Endpoint Router Enums](https://github.com/hankyeol-dev/Runwithu/tree/main/runwithu/Service/API)

1️⃣ 고민한 부분

- 서버 API는 엔드포인트 별로 body/header/method 등의 네트워크 통신 객체 구성 명세가 상이했습니다.
  - 요청마다 반복적인 통신 객체를 생성하는 것은 비효율적이라 판단했습니다. 엔드포인트에 따라 필요한 통신 객체를 맵핑해주는 단일 구조가 필요했습니다.

2️⃣ 고민을 풀어낸 방식

- 엔드포인트마다 **URI 구성(Endpoint, Parameters) 및 HTTP 통신을 위해 필요한 요소(Method, Body, Header)를 하나의 객체에서 연산하도록 명세**하는 [Endpoint 프로토콜](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Protocol/EndPoint.swift) 을 구성했습니다. 프로토콜 구성을 위해 `Moya` 라이브러리의 `TargetType 프로토콜` 을 참고하였습니다.

  ```swift
  protocol EndPointProtocol {
     var isNeedToken: Bool { get }
     var path: String { get }
     var endPoint: String { get }
     var method: NetworkMethod { get }
     var headers: [String: String]? { get }
     var parameters: [URLQueryItem]? { get }
     var body: Data? { get }
  }
  ```

- User, Post, Auth 요청을 구분해서 엔드포인트 별로 케이스를 나누고, Endpoint 프로토콜을 채택하여, **케이스 별로 통신 객체를 맵핑하는 Router Enum**을 구현했습니다.

  ```swift
  // 회원가입, 로그인, 이메일 중복 검증 등의 라우팅 처리
  enum UserEndPoint: EndPointProtocol {
      case join(input: JoinInput)
      case login(input: LoginInput)
      ...
      var body: Data? {
         switch self {
         case let .join(input):
            return input.converToJSON()
         case let .login(input):
            return input.converToJSON()
         }
      }
  }
  ```

  - body, parameter 구성에 필요한 정보는 **InputType으로 구조화**했습니다. Router마다 어떤 데이터가 필요한지를 InputType로 컴파일 단계에서 명확히 할 수 있었습니다. InputType이 Encodable을 채택하게 만들고, Encodable 프로토콜 확장부에서 JSON으로 인코딩하는 함수를 구현해 body 구성에 활용했습니다.

- Endpoint 프로토콜 확장부에서는 **연산 프로퍼티를 조합하여 통신에 필요한 URL과 Request 객체를 맵핑하는 메서드를 구현**했습니다. Actor로 관리하는 토큰(access,refresh)을 활용하기 위해 async 메서드로 구성했습니다. 메서드 구현을 위해 `Alamofire` 라이브러리의 `URLRequestConvertible 프로토콜` 을 참고했습니다.

  ```swift
   extension EndPointProtocol {
      ...
      func asURLRequest() async throws -> URLRequest {
         let url = try asURL()
         do {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue

            if let headers {
               if isNeedToken {
                  let accessToken = try await TokenManager.shared.readAccessToken()
                  request.setValue(value, forHTTPHeaderField: AppEnvironment.headerAuthKey)
               }
               for (key, value) in headers {
                  request.setValue(value, forHTTPHeaderField: key)
               }
            }

            if let body {
               request.body = body
            }

            return request
         } catch {
            throw NetworkErrors.invalidRequest
         }
      }
   }
  ```

  - 이미지를 포함한 대용량 파일 업로드는 multipart/form-data 형식으로 body에 들어갈 데이터 타입을 정의해줘야 했습니다. 이를 위해 **Endpoint 프로토콜 확장부에서 `asMultipartFileDatas` 라는 메서드를 구현**하였습니다. 메서드 구현을 위해 Alamofire의 upload api 중 `multipart.append` 구현부를 확인했습니다. boundary 라고 하는 고유한 문자열을 통해 multi part로 잘라서 보내는 데이터의 요청 범위를 구분했고, boundary 내에서 파일 이름과 형식을 지정해 업로드를 위한 데이터 그룹을 맵핑했습니다.

  ```swift
  func asMultipartFileDatas(for boundary: String, key: String, values: [Data], filename: String) -> Data {
     let crlf = "\r\n"
     let dataSet = Data()

     values.forEach {
        dataSet.append("--\(boundary)\(crlf)".data(using: .utf8)!)
        dataSet.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\(crlf)".data(using: .utf8)!)
        dataSet.append("Content-Type: image/png\(crlf)\(crlf)".data(using: .utf8)!) // 업로드 할 이미지 파일 형식
        dataSet.append($0)
        dataSet.append("\(crlf)".data(using: .utf8)!)
     }
     dataSet.append("--\(boundary)--\(crlf)".data(using: .utf8)!)

     return dataSet
  }
  ```

- 네트워크 통신을 위해 활용되는 request 메서드에서는 첫 번째 인자로 Endpoint 프로토콜을 받았습니다. **endpoint별로 유연하게 URLRequest 객체를 만들 수 있도록 메서드를 추상화** 했습니다.

3️⃣ 아쉬운 점과 개선 방향

- 활용하는 엔드포인트 케이스가 늘어날수록 Routing Enum에 추가할 것이 늘어나는 구조라고 판단되었습니다. 이번 프로젝트에서는 기능 구현을 위해 선택적으로 서버의 API를 활용했지만, 프로젝트 기획이 확장되면 유지 보수가 편한 코드로 전환이 필요할 것 같습니다.
- Routing 추상화 단계를 엔드포인트 수준이 아닌, 요청별로 *Routing과 InputType을 합친 하나의 구조체*로 맵핑하면 구조가 명확하면서 유지 보수가 편하지 않을까 하고 고민해볼 수 있었습니다.

<br />

### 2. Swift Concurrency 기반의 비동기 태스크 동시성 관리

> 관련 코드: [NetworkService](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Service/API/Network.swift)

1️⃣ 고민한 부분

- 비동기로 동작하는 네트워크 통신 함수의 인자로 트레일링 탈출 클로저를 받아 내부 로직에서 통신 결과(성공, 실패)를 활용하는 방법을 고려했습니다.
  - 이전 프로젝트 경험에 비추었을 때, 클로저 구문 안에서만 비동기 태스크의 완료 시점을 인식할 수 있어, 요청마다 클로저 구문의 뎁스가 깊어졌습니다.
  - 또한, 클로저 구문에서 에러 핸들링 로직을 고려하지 않아도 통신에는 문제가 없어 휴먼 에러가 발생할 수 있다고 판단했습니다.

2️⃣ 고민을 풀어낸 부분

- **트레일링 클로저 없이 비동기 네트워크 통신 결과와 에러를 핸들링 하기 위해 `async throw -> returnType` 형태로 네트워크 통신 함수를 구현**했습니다.

  - 비동기 컨텍스트 안에서 `try await` 로 태스크 종료 시점을 인지하고 반환값을 동기적인 시퀀스로 활용할 수 있었습니다. async로 정의된 함수도 비동기 컨텍스트를 가지기 때문에, 중복된 클로저 없이 await로 또 다른 비동기 태스크 결과를 활용할 수 있었습니다.

  ```swift
   func request<D: Decodable>(by endPoint: EndPointProtocol, of outputType: D.Type) async throws -> D {
      let request = try await endPoint.asURLRequest()
      let (data, response) = try await session.data(for: request)

      do {
         // 비동기 태스크의 결과(성공, 실패 모두) 반환
         return try await handleResponse(data: data, response: response)
      } catch NetworkErrors.needToRefreshAccessToken {
         // access token 갱신 로직
      } catch {
         // error handling 로직
      }
   }
  ```
 <img width="700" alt="스크린샷 2024-11-01 오전 11 38 20" src="https://github.com/user-attachments/assets/ec2c6caf-537c-49cf-9d46-444ab512b9a4">

<br />

- **ViewModel에서는 동기적인 환경에서 async한 통신 함수 결과를 컨트롤해야 했습니다. Swift Concurrency에서 제공하는 Task를 이용해 의도적인 비동기 컨텍스트를 생성하고, 그 안에서 태스크를 처리하여 View가 구독할 수 있는 Observable로 방출** 할 수 있었습니다.

  - request 메서드가 에러를 방출할 수 있기 때문에 (throw function), `do - catch` 구문을 활용하여 비동기 태스크가 종료된 시점에서 명확하게 에러를 통제할 수 있었습니다.

  ```swift
   func transform() {
      ...
      input.getPostInput
         .bind(with: self) { viewModel, _ in
            // 동기적인 이벤트 구독 컨텍스트에서 의도적으로 비동기 태스크를 처리할 수 있도록 Task로 환경 설정
            Task {
               await viewModel.getPost(
                  successEmitter: output.getPostsOutput,
                  errorEmitter: output.errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
   }

   // 비동기 태스크인 네트워크 요청을 수행하기 위한 또 다른 비동기 태스크 생성
   private func getPost(successEmitter: PublishSubject<PostOutput>, errorEmitter: PublishSubject<ErrorOutput>) async {
      let getPostInput: GetPostInput = .init(id: postId)
      do {
         let output = try await networkManager.request(
            by: PostEndPoint.getPost(input: getPostInput),
            of: PostOutput.self)
         successEmitter.onNext(output)
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.outputNotFound)
      }
   }
  ```

- 유저가 작성한 커뮤니티 글 id가 담긴 1. 배열을 순회하면서 2. 연관된 다른 글을 불러와 3. 필터링하는 로직을 구현해야 했습니다. 반복문을 통해 **동일한 비동기 태스크 컨텍스트에서 1.여러 번의 독립된 비동기 태스크를 생성해야 했고, 2.개별 태스크가 모두 종료된 시점에 3.필터링이 진행**되어야 했습니다.

  - **반복적인 비동기 태스크 처리를 위해 1. `withTaskGroup` 메서드를 활용**했습니다. `async let`을 활용하여 핸들링 할 수 있었지만, 반복이 종료된 시점에 2. 결과를 한번에 3. 필터링해서 반환하는 것이 더 효율적이라고 판단하여 TaskGroup을 활용했습니다. async - await 구문을 활용하지 않았다면, DispatchGroup을 활용하여 개별 비동기 태스크의 종료 시점을 notify 확인하였을 것 같습니다.

    ```swift
    var postsList: [PostsOutput] = []

    await withTaskGroup(of: PostsOutput?.self) { group in
       postsIds.forEach { id in
          group.addTask { [weak self] in
             do {
                return try await self?.networkManager.request(
                   by: PostEndPoint.getPost(input: .init(post_id: id)),
                   of: PostsOutput.self
                )
             } catch {
                return nil
             }
          }
       }

       for await post in group {
          postsList.append(post)
       }
    }

    filteringPosts(postsList)
    ```

<br />

### 3. Actor 객체를 활용한 JWT 기반 토큰 관리

> 관련 코드: [TokenManager](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Service/Auth/TokenManager.swift), [UserDefaultsManager](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Service/Auth/UserDefaultsManager.swift)

1️⃣ 고민한 부분

- 대부분의 API 통신에서 JWT 기반의 Access/Refresh 토큰이 사용되었습니다. 요청을 보낸 유저를 인증하고 자원 접근 권한을 확인하는 목적으로 활용되었습니다.

  - API 통신을 위해, 발급된 Access / Refresh 토큰을 효율적으로 관리하는 방법이 필요했습니다.
  - 여러 비동기 컨텍스트에서 토큰이라는 하나의 공유 자원에 동시적으로 접근되는 상황도 관리해야 했습니다. 동일 관점에서, 토큰이 갱신되면 Data Race 없이 독립적인 비동기 태스크(API 통신 태스크)가 처리될 수 있어야 했습니다.

2️⃣ 고민을 풀어낸 부분

- **앱이 동작하는 동안, 여러 객체에서 동일한 토큰을 참조하여 서버에 요청을 보내기 위해 [토큰 매니저 객체](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Service/Auth/TokenManager.swift)를 Actor 기반의 싱글톤 객체로 구현**했습니다.

  - 특정 View를 그리고 업데이트 하기 위해 독립적인 통신 태스크가 동시에 호출될 수 있었습니다. 이런 상황에서 동시에 토큰을 갱신한다면, data race로 이후 통신에 대한 무결성을 확신할 수 없었습니다. 그래서, **토큰에 접근하고 업데이트하는 과정을 모든 통신 태스크가 await로 기다리도록 제약하기 위해 Actor를 활용**했습니다.

  ```swift
   actor TokenManager {
      static let shared = TokenManager()

      private init() {}

      private enum encryptKeys: String {
         case access = "accessKey"
         case refresh = "refreshKey"
      }

      func registerAccessToken(by tokenKey: encryptKeys, token: String) -> Bool {
         // 키체인에 토큰을 저장하는 로직 반영
      }

      func readToken(by tokenKey: encryptKeys) throws -> String {
         do {
            return try readToken(by: tokenKey)
         } catch {
            throw TokenErrors.notFoundTokenError
         }
      }
      ...
   }
  ```

- 5분이라는 짧은 토큰 만료 시점에 맞춰 새로운 토큰으로 갱신하는 로직도 필요했습니다. 네트워크 통신마다 토큰이 필요했기 때문에 토큰 매니저에 `refreshToken` 메서드를 구현했습니다.

  ```swift
    // TokenManager
    func refreshToken() async -> Bool {
       do {
          let access = try readToken(by: .access)
          let refresh = try readToken(by: .refresh)
          let refreshTokenInput: RefreshTokenInput = .init(accessToken: access, refreshToken: refresh)

          let newToken = try await NetworkService.shared.request(
             by: AuthEndPoint.refreshToken(input: refreshTokenInput),
             of: RefreshTokenOutput.self
          )

          return registerToken(by: .access, token: newToken.access) && registerToken(by: .refresh, token: newToken.refresh)
       } catch {
          return false
       }
    }
  ```

  - 네트워크 요청 메서드에서는, **토큰 갱신 에러가 반환될 경우 refreshToken 메서드를 호출하여 통신 흐름이 끊기지 않도록 구현**했습니다. 토큰 갱신이 정상적으로 처리되면 request 메서드를 재귀적으로 호출하여 최초 통신 결과를 반환했습니다. request 메서드가 Swift Concurrency 기반으로 작성되었기 때문에, await로 토큰 매니저에 접근할 수 있었습니다.

  - Refresh 토큰 갱신이 필요한 경우에는 `needToRefreshRefreshToken` 이라는 에러를 던져 유저가 다시 로그인을 할 수 있도록 유도했습니다.
    ```swift
       func request<D: Decodable>(by endpoint: EndpointProtocol, of output: D.Type) async throws {
       ...
       catch NetworkErrors.needToRefreshAccessToken {
          if await tokenManager.refreshToken() {
             // 1. 엑세스 토큰 갱신에 성공한 경우, 다시 재귀적으로 request 메서드 호출
             return try await self.request(by: endPoint)
          } else {
             // 2. 리프레시 토큰도 갱신이 필요한 경우, 관련 에러 방출
             throw NetworkErrors.needToRefreshRefreshToken
          }
       }
    }
    ```

3️⃣ 아쉬운 점과 개선 방향

- 토큰 매니저 내부에서 Keychain을 이용해 토큰의 저장, 읽기, 업데이트를 구현했습니다. 앱 사용 권한을 인증 받는 정보이기 때문에 암호화된 데이터베이스에 저장하는 것이 맞다고 판단하였습니다.
- 다만, 토큰이 짧은 주기로 갱신된다는 점, 앱 기반이 아닌 디바이스 기반으로 저장되어 다른 앱에서도 (권한 설정이 필요하지만) 활용될 수 있다는 점이 아쉬웠습니다. 또한, 네트워크 요청마다 토큰이 사용되기 때문에 읽기/쓰기 속도가 중요하고 비슷한 역할을 하는 UserDefaults 보다 느릴 수 있다는 점 역시 아쉬웠습니다.
  - UserDefaults 역시 Actor 기반의 싱글톤 객체([UserDefaultsManager](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Service/Auth/UserDefaultsManager.swift))로 관리하고 있었기 때문에, 두 객체를 통합하는 것도 괜찮을 것이라는 고민을 할 수 있었습니다.

<br />

## 프로젝트 페이지별 기능

| 1. 러닝 초대장 작성                                                                                       | 2. 팔로우 러너 초대                                                                                       | 3. 러닝 초대장 상세                                                                                       | 4.마이페이지 초대장 확인                                                                                  |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/8a2fb47b-39b2-484e-993a-23a7d70a6ee3" /> | <img width="200" src="https://github.com/user-attachments/assets/ff7a7bec-5008-4f42-8d73-ef75c93e1370" /> | <img width="200" src="https://github.com/user-attachments/assets/cbe05b42-59a6-4df2-9e82-09a345c6cd34" /> | <img width="200" src="https://github.com/user-attachments/assets/d1825ea8-06bc-4d3b-9c82-e7a659e98454" /> |

- 앱에서 다른 유저에게 **함께 달리기 초대장을 작성하여 보낼 수 있습니다.**
  - 초대장을 받은 유저는 <u>마이페이지에서 초대장 상세 페이지를 확인</u> 할 수 있습니다.
  - 초대장 상세 페이지에서 함께 달리기 초대에 응할 수 있고, 거절 할 수도 있습니다.
  - 함께 달리기 날짜가 지난 초대장은 다른 유저들에게 더 이상 조회되지 않도록 설정했습니다.

<br />

| 5. 러닝 커뮤니티 선택                                                                                     | 6. 러닝 일지 작성                                                                                         | 7. 러닝 일지 리스트                                                                                       | 4. 러닝 일지 상세                                                                                         |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/9c339c55-ed5f-42e4-b1c1-2164421586b3" /> | <img width="200" src="https://github.com/user-attachments/assets/e1e5468e-3846-4575-b4fa-a02029e1e86d" /> | <img width="200" src="https://github.com/user-attachments/assets/81faee32-1e46-42d8-acb4-e8c039300cf9" /> | <img width="200" src="https://github.com/user-attachments/assets/4bcf5e25-1241-4592-9317-f3df06ccd4f4" /> |

- **러닝 커뮤니티 글 작성 - 러닝 일지**
  - 러닝 경험을 다른 유저들과 **함께 공유하고, 공감하고, 댓글**을 주고 받을 수 있습니다. (데일리/특정 날짜 선택 후 작성 가능)
  - 러닝 일지에는 그날의 **사진을 등록**할 수 있고, 일지 목록에서는 그 사진을 함께 확인하고 상세 화면에서도 내용과 함께 확인이 가능합니다.

<br />

| 9. QnA 작성                                                                                               | 10. QnA 목록                                                                                              | 11. 용품 후기 작성                                                                                        | 12. 용품 후기 상세                                                                                        |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/fd217f04-19f0-4b1b-87b0-e446f1700d10" /> | <img width="200" src="https://github.com/user-attachments/assets/c51327dd-3fc8-4954-b18a-8bfe624fb909" /> | <img width="200" src="https://github.com/user-attachments/assets/7067d5ef-b101-4d35-ae1e-60cc6a457c95" /> | <img width="200" src="https://github.com/user-attachments/assets/35150469-ee5a-4c16-919e-43e4f35b2aad" /> |

- **러닝 커뮤니티 글 작성 - 러닝 QnA, 러닝 기어 후기**
  - 다른 러너들에게 러닝과 관련된 다양한 질문을 남기고 댓글로 답변 받을 수 있습니다.
  - 러너들에게 중요한 러닝 기어(러닝화, 러닝복, 기타 러닝 용품 등)에 대한 솔직한 리뷰를 다른 러너들과 공유할 수 있습니다.

<br />

| 13. 마라톤 목록                                                                                           | 14. 참가비 결제 1                                                                                         | 15. 참가비 결제 2                                                                                         |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| <img width="200" src="https://github.com/user-attachments/assets/e23f897e-2996-48fc-a1bd-84df755eadbf" /> | <img width="200" src="https://github.com/user-attachments/assets/9076bd8f-115c-479e-9fe3-d3dea3c8759e" /> | <img width="200" src="https://github.com/user-attachments/assets/df6bde92-a2a1-4167-aad1-16ff8b4918aa" /> |

- **마라톤 대회 목록 조회**
  - 마라톤 대회에 대한 정보를 모아볼 수 있습니다.
  - 목록에서 참가를 희망하는 대회에 참가신청 하고, 참가비를 결제할 수 있습니다.

<br />
