# 함께 달려요 RunwithU

## 프로젝트 소개
러닝과 관련된 커뮤니티 글을 작성하고, 나만의 러닝 그룹을 만들어 다른 러너들과 소통하며, 함께 달리기 초대장을 보낼 수 있는 러닝 전문 커뮤니티 서비스

- 참여자: 강한결 (hankyeol-dev, 1인 프로젝트)
- 구현 기간
  - 1차: **2024.08.15 ~ 09.01**  (Basic Implementation 기능/UI 구현)
  - 2차: **2024.09.02 ~ 09.07** (결제 및 UI 코드 정리)
- 최소 지원 버전: iOS 15.0+

### 구현 스택 
> - **UIKit, RxSwift** 
> - **URLSession + Swift Concurrency + Actor 객체를 활용한 비동기 통신 관리**  
> - **포트원(IamPort) PG SDK를 활용한 결제 및 결제 영수증 유효성 검증**

- 구현 방식
  - 코드 패턴: `In-Out MVVM 패턴`
  - RxSwift 라이브러리로 **UI - User Event간의 대한 비동기적인 처리**를 관리할 수 있었습니다. (모든 UI Action을 RxSwift로 관리)
    - UI에 바인딩되는 액션의 입출력을 **ViewModel의 In-Out 구조체를 활용하여 직관적으로 관리**할 수 있었습니다.
    - 유저의 스크에 따라 커서 기반의 페이지네이션을 Rx로 비동기 이벤트 관리할 수 있었습니다.
  - Swift Concurrency의 **async-await 구문, actor 객체를 통해 Network API 통신과 전역적 데이터 상태를 관리**하였습니다.
    - Task, TaskGroup을 통해 비동기 컨텍스트를 의도적으로 만들고, 비동기적인 통신의 흐름을 await 키워드로 관리하였습니다.
    - TokenManager, UserDefaultsManager와 같이 여러 통신에서 동시적으로 접근될 수 있는 값/객체는 Actor로 구현하여 Data Race 상태를 방지할 수 있었습니다. 
  - Network 통신에는 **커스텀 Endpoint Router 패턴**을 접목한 URLSession API를 활용하였습니다.
    - Moya + Alamofire의 `URLRequestConvertible` 프로토콜을 참고하여 커스텀한 [Endpoint Protocol](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Protocol/EndPoint.swift)로 fetch, post, upload 요청 객체를 운용할 수 있었습니다.
    -  API 통신별로 필요한 DTO(Input, Output 타입) 객체를 Router 패턴에 구조화하여 활용하였습니다.

### 프로젝트 구현 페이지 및 기능

|1. 러닝 초대장 작성|2. 팔로우 러너 초대|3. 러닝 초대장 상세|4.마이페이지 초대장 확인|
|-|-|-|--|
|<img width="200" src="https://github.com/user-attachments/assets/8a2fb47b-39b2-484e-993a-23a7d70a6ee3" />|<img width="200" src="https://github.com/user-attachments/assets/ff7a7bec-5008-4f42-8d73-ef75c93e1370" />|<img width="200" src="https://github.com/user-attachments/assets/cbe05b42-59a6-4df2-9e82-09a345c6cd34" />|<img width="200" src="https://github.com/user-attachments/assets/d1825ea8-06bc-4d3b-9c82-e7a659e98454" />|

- 앱에서 다른 유저에게 **함께 달리기 초대장을 작성하여 보낼 수 있습니다.** 
  - 초대장을 받은 유저는 <u>마이페이지에서 초대장 상세 페이지를 확인</u> 할 수 있습니다.
  - 초대장 상세 페이지에서 함께 달리기 초대에 응할 수 있고, 거절 할 수도 있습니다.
  - 함께 달리기 날짜가 지난 초대장은 다른 유저들에게 더 이상 조회되지 않도록 설정했습니다.

<br />

|5. 러닝 커뮤니티 선택|6. 러닝 일지 작성|7. 러닝 일지 리스트|4. 러닝 일지 상세|
|--|-|-|--|
|<img width="200" src="https://github.com/user-attachments/assets/9c339c55-ed5f-42e4-b1c1-2164421586b3" />|<img width="200" src="https://github.com/user-attachments/assets/e1e5468e-3846-4575-b4fa-a02029e1e86d" />|<img width="200" src="https://github.com/user-attachments/assets/81faee32-1e46-42d8-acb4-e8c039300cf9" />|<img width="200" src="https://github.com/user-attachments/assets/4bcf5e25-1241-4592-9317-f3df06ccd4f4" />|

- **러닝 커뮤니티 글 작성 - 러닝 일지**
  - 러닝 경험을 다른 유저들과 **함께 공유하고, 공감하고, 댓글**을 주고 받을 수 있습니다. (데일리/특정 날짜 선택 후 작성 가능)
  - 러닝 일지에는 그날의 **사진을 등록**할 수 있고, 일지 목록에서는 그 사진을 함께 확인하고 상세 화면에서도 내용과 함께 확인이 가능합니다.

<br />

|9. QnA 작성|10. QnA 목록|11. 용품 후기 작성|12. 용품 후기 상세|
|--|--|-|--|
|<img width="200" src="https://github.com/user-attachments/assets/fd217f04-19f0-4b1b-87b0-e446f1700d10" />|<img width="200" src="https://github.com/user-attachments/assets/c51327dd-3fc8-4954-b18a-8bfe624fb909" />|<img width="200" src="https://github.com/user-attachments/assets/7067d5ef-b101-4d35-ae1e-60cc6a457c95" />|<img width="200" src="https://github.com/user-attachments/assets/35150469-ee5a-4c16-919e-43e4f35b2aad" />|

- **러닝 커뮤니티 글 작성 - 러닝 QnA, 러닝 기어 후기**
  - 다른 러너들에게 러닝과 관련된 다양한 질문을 남기고 댓글로 답변 받을 수 있습니다.
  - 러너들에게 중요한 러닝 기어(러닝화, 러닝복, 기타 러닝 용품 등)에 대한 솔직한 리뷰를 다른 러너들과 공유할 수 있습니다.

<br />

|13. 마라톤 목록|14. 참가비 결제 1|15. 참가비 결제 2|
|--|--|--|
|<img width="200" src="https://github.com/user-attachments/assets/e23f897e-2996-48fc-a1bd-84df755eadbf" />|<img width="200" src="https://github.com/user-attachments/assets/9076bd8f-115c-479e-9fe3-d3dea3c8759e" />|<img width="200" src="https://github.com/user-attachments/assets/df6bde92-a2a1-4167-aad1-16ff8b4918aa" />|

- **마라톤 대회 목록 조회**
  - 마라톤 대회에 대한 정보를 모아볼 수 있습니다. 
  - 목록에서 참가를 희망하는 대회에 참가신청 하고, 참가비를 결제할 수 있습니다.


<br />

## 프로젝트에서 고민한 것들

### Endpoint Protocol 구성을 통한 네트워크 통신 객체 Router 패턴 적용
- 서버 통신을 위한 API의 요청별 엔드포인트, body/header/method 등에 대한 통신 객체 구성의 명세가 다양했습니다.
  - 1️⃣  각 요청 엔드포인트별로 각기 다른 요청 객체를 반환할 수 있는 [Endpoint Protocol](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Protocol/EndPoint.swift)을 구성해 활용했습니다.
    - 프로토콜 구현을 위해 Moya 라이브러리의 TargetType 프로토콜에 구현된 요청 객체 구조화와 Alamofire 라이브러리의 URLConvertible 프로토콜에 구현된 asURL 메서드를 참고하였습니다.
    - 엔드포인트에 대한 열거형 케이스를 만들고, 각 엔드포인트별로 endpoint, method, body, header, parameters 구성을 연산 프로퍼티로 맵핑될 수 있게 하였습니다.
    - protocol 확장부에서는 header를 구성하고, body를 반영하여 Request URL로 반환하는 asURLRequest 메서드를 반영했습니다.
      - 요청 객체 헤더에 토큰이 반영되어야 했기 때문에 TokenManager 접근을 위해 async한 함수로 구성했습니다.
      ``` swift
      protocol EndPointProtocol {
         var isNeedToken: Bool { get }
         var path: String { get }
         var endPoint: String { get }
         var method: NetworkMethod { get }
         var headers: [String: String]? { get }
         var parameters: [URLQueryItem]? { get }
         var body: Data? { get }
      }
  
      extension EndPointProtocol {
         func asURLRequest() async throws -> URLRequest {
            do {
               let url = try asURL()
               
               var request = URLRequest(url: url)
               
               request.httpMethod = method.rawValue
               
               if let headers {
                  for (key, value) in headers {
                     request.setValue(value, forHTTPHeaderField: key)
                  }
                  
                  if isNeedToken {
                     let accessToken = try await TokenManager.shared.readAccessToken()
                     request.setValue(accessToken, forHTTPHeaderField: AppEnvironment.headerAuthKey)
                  }
               }
               
               if let body {
                  request.httpBody = body
               }
               
               return request
            } catch {
               throw NetworkErrors.invalidRequest
            }
         }
      }
      ```
  - 2️⃣ 엔드포인트를 활용하는 부분에서는 각 요청에 필요한 정보를 InputType 형태로 구조화하여 활용했습니다.
    - InputType 객체를 통해, 라우터 활용 부분에서는 어떤 데이터 필요로 하는지를 컴파일 단계에서 명확히 할 수 있었습니다.
    - 뷰 단에서도 어떤 데이터를 받아와야 할 지 명확해질 수 있었습니다.
    ``` swift
    enum UserEndPoint: EndPointProtocol {
       case join(input: JoinInput)
       case login(input: LoginInput)
       case validEmail(input: ValidEmailInput)
       case readMyProfile
       case readAnotherProfile(input: ProfileInput)
       case searchUserByNick(input: SearchUserByNickInput)
       case updateProfile(input: ProfileUpdateInput)
       case updateProfileImage(input: ProfileImageUpdateInput)
       case follow(input: FollowInput)
    ..
    }
    ```
  - 3️⃣ 아쉬운 점 및 개선 방향
    -  API 엔드포인트 케이스를 추가할 때마다 열거형이 비대해지고, Endpoint 구성 항목별 switch문을 매번 수정해야 하는 번거로움이 있었습니다.
    - 추상화 단계를 엔드포인트 수준으로 하는 것이 아닌, 요청별로 각기 다른 구조체를 가질 수 있도록 한다면 구조에 대한 명확성이 높아지고 유지 보수가 편하지 않을까 하는 고민을 해볼 수 있었습니다.

<br />

### Swift Concurrency를 통한 비동기 작업의 동시성 관리
- 서버 통신 결과로 받아온 데이터를 내부 API로 다시 뷰를 그리는데 필요한 형태로 맵핑해줘야 하는 경우가 많았습니다. 
  - 1️⃣ 비동기 함수 내부에서 클로저 형태로 데이터 맵핑을 하는 방법을 고려했습니다.
    - 이런 경우, (이전 다른 프로젝트 경험에서) 매 요청마다 클로저 구문의 뎁스가 깊어졌고
    - 클로저 구문 자체에서 에러를 핸들링하는 로직을 스스로 고려하지 않는다면 (에러 핸들링을 위한 클로저를 따로 두던지, ResultType 형태로 따로 한 번 더 결과를 맵핑하는 방식 등) 휴먼 에러가 발생할 수 있다고 판단했습니다.
  - 2️⃣ 비동기 네트워크 통신에 대한 시점을 컨트롤 하고 에러까지 고려할 수 있는 async throws 형태로 네트워크 통신 코드를 작성해 프로젝트 전반에 활용했습니다.
    ``` swift
     func request<D: Decodable>(
        by endPoint: EndPointProtocol,
        of outputType: D.Type
     ) async throws -> D {
        let request = try await endPoint.asURLRequest()
        let (data, response) = try await session.data(for: request)
              
        do {
           return try await handleResponse(data: data, response: response)
        } catch NetworkErrors.needToRefreshAccessToken {
           let refreshResult = await tokenManager.refreshToken()
           if refreshResult {
              return try await self.request(by: endPoint, of: outputType)
           } else {
              throw NetworkErrors.needToRefreshRefreshToken
           }
        } catch {
           return try await handleResponse(data: data, response: response)
        }
     }
    ```
    - 활용하는 부분에서는, 동시적 태스크로 요청한 비동기 네트워크 통신 결과가 도착하는 시점을 await 키워드로 파악할 수 있었고,
    - do - catch 구문으로 반환되는 error case에 따라 에러를 통신 시점 이후에 컨트롤 할 수 있었으며,
    - Task 를 이용해 비동기 컨텍스트를 의도적으로 만들어, 통신에 따라 뷰가 멈추는 과정 없이 뷰를 위한 데이터 내부 api로 맵핑할 수 있었습니다. (내부적으로 맵핑한 데이터를 Rx Observable로 뷰에 전달)
      ``` swift
      // 활용 예시 - 회원 가입 로직

       private func join(
          errorEmitter: PublishSubject<String>?,
          successJoinEmitter: PublishSubject<JoinOutput>
       ) async {
          let joinInput = JoinInput(
             email: email,
             password: password,
             nick: nickname,
             phoneNum: nil,
             birthDay: nil
          )
          
          do {
             let result = try await networkManager.request(
                by: UserEndPoint.join(input: joinInput),
                of: JoinOutput.self
             )
             successJoinEmitter.onNext(result)
          } catch NetworkErrors.invalidResponse {
             errorEmitter?.onNext("이미 사용중인 계정이에요.")
          } catch NetworkErrors.overlapUsername {
             errorEmitter?.onNext("이미 사용중인 러너이름이에요.")
          } catch {
             errorEmitter?.onNext("알 수 없는 에러가 발생했어요. 잠시 후 다시 시도해주세요.")
          }
       }
      ```

<br />

### 앱 접근 및 사용 권한 확보를 위한 JWT 기반의 서버 권한/인증 API 활용 (토큰 관리와 갱신)
- 프로젝트를 진행한 서버는 앱 사용을 위한 유저의 인증/권한 확보를 위해 JWT 기반의 Auth 체계가 있었습니다.
  - 1️⃣ *대부분의 네트워크 통신에 토큰이 필요한 상황과 한 번에 토큰이 여러번 활용될 수 있는 경우 대응
    - 서버 네트워크 통신 객체가 필요로 하는 토큰 정보를 참조할 수 있는 전역적인 싱글턴 형태의 매니저 객체를 두었습니다. ([TokenManager](https://github.com/hankyeol-dev/Runwithu/blob/main/runwithu/Service/Auth/TokenManager.swift))
    - 하나의 뷰를 그리기 위해서 동시적으로 여러 개의 비동기 태스크가 동작할 수 있었고, 각각의 통신에서 한번에 토큰 데이터를 활용할 수 있었습니다. 
      - 이럴 경우, 토큰이 중간에 리프레시되어 의도치 않은 에러를 발생시킬 수 있을 것이라는 판단이 내려졌습니다.
      - 이 문제를 해결하기 위해, 하나의 통신 객체만 토큰 객체에 접근할 수 있도록 제어할 수 있는 Actor로 Token 매니저를 구축했습니다.
      - 모든 통신이 토큰에 대한 접근을 await로 기다려야 했고, 그 전의 통신이 토큰을 갱신시키더라도 다음 통신은 안전하게 갱신된 토큰을 참조하게 만들 수 있었습니다.
      ```swift
      actor TokenManager {
         static let shared = TokenManager()
         ...
          func refreshToken() async -> Bool {
            do {
               let access = try readAccessToken()
               let refresh = try readRefreshToken()
               let refreshTokenInput: RefreshTokenInput = .init(accessToken: access, refreshToken: refresh)
               
               let newAccessToken = try await NetworkService.shared.request(
                  by: AuthEndPoint.refreshToken(input: refreshTokenInput),
                  of: RefreshTokenOutput.self
               ).accessToken
               
               return registerAccessToken(by: newAccessToken)
            } catch {
               return false
            }
         }
      }
      ```
  - 2️⃣ 짧은 토큰 갱신 시점에 대한 대응
    - 5~10분으로 짧은 Access Token 만료 시점과 최대 1시간으로 설정된 Refresh Token 만료에 대한 토큰 갱신이 필요했습니다.
    - 모든 네트워크 통신을 위한 코드에서 토큰 권한을 체크하는 과정을 반영하였습니다. 
      - 응답 객체를 인자로 받아 Status Code에 따라 토큰 갱신이 필요한 경우 에러를 던질 수 있게 구성했습니다.
      - 에러가 캐치된 시점에서는, Token Manager 내부의 refresh 로직이 동기적으로 실행됩니다. 
      - 그 실행 결과에 따라 다시 통신 api가 동작되어야 하는지, 아니면 최종적으로 에러를 던지고 함수가 종료되어야 하는지 결정하는 순서로 모든 통신에 대한 토큰을 관리할 수 있었습니다.
      ```swift
        func someNetwork() async throws {
        .. 
          do {
               if !(200..<300).contains(response.statusCode) {
                  try await handleStatusCode(statusCode: response.statusCode)
               }
            } catch NetworkErrors.needToRefreshAccessToken {
               let refreshResult = await tokenManager.refreshToken()
               if refreshResult {
                  return try await self.request(by: endPoint)
               } else {
                  throw NetworkErrors.needToRefreshRefreshToken
               }
            } catch { }
        }
      ```
  - 3️⃣ 아쉬운 점 및 개선 방향성
    - 내부적으로 token을 기기 keychain에 저장하여 읽고 쓰도록 처리하였습니다. 보안의 목적으로, 앱 자체에 종속성을 가지는 UserDefaults를 이용하는 것이 더 좋지 않았을까 하는 아쉬움이 있습니다.

*대부분인 이유는, 회원가입/이메일 중복 확인 등의 '권한 확보'를 위한 선행적인 통신은 토큰이 불필요 했습니다.

<br />

### MVVM 패턴에서 In-Out 방식으로 이벤트에 따른 데이터 흐름 관리

- ViewModel에 Input, Output으로 구조화된 객체를 활용하여 ViewController의 이벤트를 감지하고, 내부 로직으로 데이터가 필요한 형태로 반환될 수 있게 관리했습니다.
  - 1️⃣ 모든 ViewController와 ViewModel의 연결이 In-Out 패턴으로 구조화 될 수 있도록 ViewModel에 대한 프로토콜을 채택시켰습니다.
    ```swift
      protocol BaseViewModelProtocol: AnyObject {
       associatedtype Input
       associatedtype Output
       
       var disposeBag: DisposeBag { get }
       var networkManager: NetworkService { get }
       
       func transform(for input: Input) -> Output
    }
    ```
    - ViewController에서는 ViewModel.Input 으로 Input 인스턴스를 만들어 이벤트가 구독될 수 있도록 처리해줍니다. transform 메서드를 통해서 반환된 Output 인스턴스를 뷰를 그리기 위해 활용하기만 하면 됩니다.
      - 이럴 경우, view에서는 내부 로직이 어떤식으로 동작하는지에는 신경쓸 필요 없이 뷰에 맞게 맵핑된 데이터를 활용하기만 하면 되었습니다.
    - ViewModel에서는 View에서 구조화되어 넘어온 Input 객체의 각 요소들을 내부 로직에 의해 Output으로 반환하는 transform 메서드 구축에만 신경쓰면 되었습니다.
  - 2️⃣ 아쉬운 점 및 개선 방향
    -  ViewController에서 Input 인스턴스를 만들고, transform 메서드를 통해 Output 인스턴스를 활용하는 로직을 하나의 메서드에서 모두 처리하도록 구성했습니다.
    - 각 output 요소들을 인자로 받아서 각각의 뷰로 맵핑하는 메서드를 구분하였다면 더 가독성 높고, 유지하기 쉬운 코드가 되지 않았을까 하는 아쉬움이 있었습니다. 

<br />

## 프로젝트 회고

- tbd 
