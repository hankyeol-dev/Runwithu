//
//  InvitationDetailView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class InvitationDetailView: BaseView, BaseViewProtocol {
   private let scrollView = BaseScrollView()
   private let invitationHeaderImage = UIImageView(image: .invitationHeader)
   private let invitationInfoBox = RectangleView(backColor: .white, radius: 8)
   private let titleView = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let contentView = BaseLabel(for: "", font: .systemFont(ofSize: 18, weight: .medium))
   private let ownerLabel = BaseLabel(for: "초대한 러너", font: .systemFont(ofSize: 16, weight: .semibold))
   private let ownerImage = BaseUserImage(size: 32, borderW: 1, borderColor: .darkGray)
   private let ownerName = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   private let invitedLabel = BaseLabel(for: "초대 받은 러너", font: .systemFont(ofSize: 16, weight: .semibold))
   private let runningCalendar = UICalendarView()
   private let runningDateLabel = BaseLabel(for: "함께 달리는 날", font: .systemFont(ofSize: 16, weight: .semibold))
   
   private let buttonStack = UIStackView()
   let joinButton = RoundedButtonView("", backColor: .systemGreen, baseColor: .white, radius: 12)
   let dismissButton = RoundedButtonView("다음번에..", backColor: .systemGray4, baseColor: .white, radius: 12)
   
   private var runningDate: DateComponents? = nil
   
   override func setSubviews() {
      super.setSubviews()
      addSubview(scrollView)
      scrollView.contentsView.addSubviews(
         invitationHeaderImage, invitationInfoBox
      )
      invitationInfoBox.addSubviews(
         titleView, contentView, ownerLabel, ownerImage, ownerName, invitedLabel, runningCalendar, 
         runningDateLabel,
         buttonStack
      )
      buttonStack.addArrangedSubview(dismissButton)
      buttonStack.addArrangedSubview(joinButton)
   }
   override func setLayout() {
      super.setLayout()
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
         make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-60)
      }
      
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      invitationHeaderImage.snp.makeConstraints { make in
         make.top.equalTo(guide).inset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(180)
      }
      invitationInfoBox.snp.makeConstraints { make in
         make.top.equalTo(invitationHeaderImage.snp.bottom).inset(72)
         make.horizontalEdges.equalTo(guide)
         make.bottom.equalTo(guide)
      }
      
      let infoGuide = invitationInfoBox.safeAreaLayoutGuide
      titleView.snp.makeConstraints { make in
         make.top.equalTo(infoGuide).inset(32)
         make.horizontalEdges.equalTo(infoGuide).inset(24)
      }
      contentView.snp.makeConstraints { make in
         make.top.equalTo(titleView.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(infoGuide).inset(24)
      }
      ownerLabel.snp.makeConstraints { make in
         make.top.equalTo(contentView.snp.bottom).offset(32)
         make.horizontalEdges.equalTo(infoGuide).inset(24)
      }
      ownerImage.snp.makeConstraints { make in
         make.top.equalTo(ownerLabel.snp.bottom).offset(10)
         make.leading.equalTo(infoGuide).inset(24)
         make.size.equalTo(32)
      }
      ownerName.snp.makeConstraints { make in
         make.centerY.equalTo(ownerImage.snp.centerY)
         make.leading.equalTo(ownerImage.snp.trailing).offset(20)
         make.trailing.equalTo(infoGuide).inset(24)
      }
      invitedLabel.snp.makeConstraints { make in
         make.top.equalTo(ownerImage.snp.bottom).offset(24)
         make.horizontalEdges.equalTo(infoGuide).inset(24)
      }
      runningDateLabel.snp.makeConstraints { make in
         make.top.equalTo(invitedLabel.snp.bottom).offset(76)
         make.horizontalEdges.equalTo(infoGuide).inset(24)
      }
      runningCalendar.snp.makeConstraints { make in
         make.top.equalTo(runningDateLabel.snp.bottom)
         make.horizontalEdges.equalTo(infoGuide).inset(16)
      }
      
      buttonStack.snp.makeConstraints { make in
         make.top.equalTo(runningCalendar.snp.bottom).offset(24)
         make.horizontalEdges.equalTo(infoGuide).inset(14)
         make.height.equalTo(56)
         make.bottom.equalTo(infoGuide).inset(24)
      }
   }
   override func setUI() {
      super.setUI()
      
      invitationHeaderImage.contentMode = .scaleAspectFit
      invitationHeaderImage.backgroundColor = .systemGray6
      invitationHeaderImage.layer.cornerRadius = 8
      invitationHeaderImage.clipsToBounds = true
      
      titleView.numberOfLines = 2
      contentView.numberOfLines = 0
      runningCalendar.calendar = .current
      runningCalendar.fontDesign = .monospaced
      runningCalendar.locale = Locale(identifier: "ko_kr")
      runningCalendar.delegate = self
      
      buttonStack.axis = .horizontal
      buttonStack.spacing = 16
      buttonStack.distribution = .fillEqually
   }
   
   func bindView(invitation: PostsOutput) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
         guard let self else { return }
         self.titleView.bindText(invitation.title)
         self.contentView.bindText(invitation.content)
         self.ownerName.bindText(invitation.creator.nick)
         
         if let ownerImageURL = invitation.creator.profileImage {
            Task {
               await self.getImageFromServer(for: self.ownerImage, by: ownerImageURL)
            }
         } else {
            self.ownerImage.image = .userSelected
         }
      }
   }
   
   func bindView(entries: [BaseProfileType]) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
         guard let self else { return }
         var entryImageViews: [UIImageView] = []
         Task {
            await withTaskGroup(of: UIImageView.self) { taskGroup in
               for entry in entries {
                  let imageView = BaseUserImage(size: 32, borderW: 0.5, borderColor: .darkGray)
                  taskGroup.addTask {
                     if let imageURL = entry.profileImage {
                        await self.getImageFromServer(for: imageView, by: imageURL)
                        return imageView
                     } else {
                        DispatchQueue.main.async {
                           imageView.image = .userSelected
                        }
                        return imageView
                     }
                  }
               }
               
               for await task in taskGroup {
                  entryImageViews.append(task)
               }
            }
            
            self.bindEntryViewLayout(for: entryImageViews)
         }
      }
   }
   
   func bindView(runningInfo: RunningInfo) {
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         let dateFormatter = DateFormatter()
         if let dateString = runningInfo.date.formattedRunningDateString() {
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
               let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
               self.runningCalendar.visibleDateComponents = components
               self.runningDate = components
               self.runningCalendar.reloadDecorations(forDateComponents: [components], animated: true)
            }
         }
      }
   }
   
   func bindView(isJoined: Bool) {
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         self.joinButton.setTitle(isJoined ? "참가 확정!" : "참가할게요!", for: .normal)
         self.joinButton.backgroundColor = isJoined ? .systemGray : .systemGreen
         self.joinButton.isEnabled = !isJoined
      }
   }
   
   private func bindEntryViewLayout(for imageViewList: [UIImageView]) {
      imageViewList.enumerated().forEach { index, imageView in
         self.invitationInfoBox.addSubview(imageView)
         imageView.backgroundColor = .white
         imageView.snp.makeConstraints { make in
            make.top.equalTo(self.invitedLabel.snp.bottom).offset(12)
            make.size.equalTo(32)
         }
         if index == 0 {
            imageView.snp.makeConstraints { make in
               make.leading.equalTo(self.invitationInfoBox.safeAreaLayoutGuide).inset(24)
            }
         } else {
            imageView.snp.makeConstraints { make in
               make.leading.equalTo(imageViewList[index - 1].snp.trailing).inset(8)
            }
         }
      }
   }
}

extension InvitationDetailView: UICalendarViewDelegate {
   func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
      if let runningDate {
         if matchingDate(start: dateComponents, end: runningDate) {
            return UICalendarView.Decoration.customView {
               let view = UILabel()
               view.text = "🏃🏻"
               return view
            }
         }
      }
      return nil
   }
   
   private func matchingDate(start: DateComponents, end: DateComponents) -> Bool {
      return start.year == end.year && start.month == end.month && start.day == end.day
   }
}
