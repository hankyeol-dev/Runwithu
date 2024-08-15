//
//  Enum+Text.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

@frozen enum Text {
   
   enum ErrorMessage: String {
      case INVALIDURL = "요청하신 주소는 유효하지 않습니다."
      case INVALIDREQUEST = "요청을 정상적으로 처리할 수 없습니다."
      case INVALIDRESPONSE = "요청에 대한 응답이 올바르지 않습니다."
      case INVALIDTOKEN = "요청에 접근할 수 없는 토큰입니다."
      case INVALIDACCESS = "요청에 접근 권한이 없습니다."
      case INVALID_UPLOAD = "업로드 요청에 문제가 있습니다."
      case DATANOTFOUND = "요청에 대한 데이터를 찾을 수 없습니다."
      case EXISTEMAIL = "이미 가입된 이메일 계정입니다."
      case ENCODE = "데이터를 인코딩 할 수 없습니다."
      case NEED_TO_REFRESH_ACCESSTOKEN = "액세스 토큰 갱신이 필요합니다."
      case NEED_TO_REFRESH_REFRESHTOKEN = "재로그인이 필요합니다."
      case NEED_TO_CONFIGURE_UPLOAD_SOURCE = "업로드하는 파일에 대한 확인이 필요합니다."
   }
}
