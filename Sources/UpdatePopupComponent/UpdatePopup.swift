//
//  UpdatePopup.swift
//  DeinDeal
//
//  Created by Dragos Marinescu on 14.02.2023.
//  Copyright © 2023 Goodshine AG. All rights reserved.
//

import Foundation

var updatePopupDateKey: String = "updatePopupKey"

public struct UpdatePopupInputData {
    
  public init(timeIntervalToShowAfterCancel: Int = 30,
                minVersion: String, recommendedVersion: String,
                bundleId: String? = nil) {
        self.timeIntervalToShowAfterCancel = timeIntervalToShowAfterCancel
        self.minVersion = minVersion
        self.recommendedVersion = recommendedVersion
        self.bundleId = bundleId
    }
    
  /// Time interval in `Days` that will be used to show again the recommended popup after the user pressed cancel. Default value is 30 days.
  public var timeIntervalToShowAfterCancel: Int = 30
  
  /// Minimum app version that will be used when deciding for `FORCE UPDATE GUI`.
  /// Can be taken from ReferenceData.settings
  public var minVersion: String
  
  /// Recommended app version that will be used when deciding for `RECOMMENDED UPDATE GUI`.
  /// Can be taken from ReferenceData.settings
  public var recommendedVersion: String
  
  /// The component is getting the value of the bundleId by calling `Bundle.main.bundleIdentifier`.
  /// If this property is passed the component will use it instead.
  public var bundleId: String?
  
  /// Use this method to update versions if they change after init
  public mutating func changeVersions(minVersion: String, recommendedVersion: String) {
    self.minVersion = minVersion
    self.recommendedVersion = recommendedVersion
  }
}

public struct UpdatePopupStringsData {
    public init(forceUpdatePopupButtonTitle: String,
                forceUpdatePopupLabelTitle: String,
                updatePopupCancelButtonTitle: String,
                updatePopupButtonTitle: String,
                updatePopupTitle: String,
                updatePopupMessage: String) {
        self.forceUpdatePopupButtonTitle = forceUpdatePopupButtonTitle
        self.forceUpdatePopupLabelTitle = forceUpdatePopupLabelTitle
        self.updatePopupCancelButtonTitle = updatePopupCancelButtonTitle
        self.updatePopupButtonTitle = updatePopupButtonTitle
        self.updatePopupTitle = updatePopupTitle
        self.updatePopupMessage = updatePopupMessage
    }
    
    /// strings for force update HUD
    public var forceUpdatePopupButtonTitle: String
    public var forceUpdatePopupLabelTitle: String
    
    /// strings for recommended version update HUD
    public var updatePopupCancelButtonTitle: String
    public var updatePopupButtonTitle: String
    public var updatePopupTitle: String
    public var updatePopupMessage: String
    
    public mutating func changeUpdatePopupMessage(newMessage: String) {
        self.updatePopupMessage = newMessage
    }
}

public protocol UpdatePopupInterface {
  var inputData: UpdatePopupInputData { get set }
  var alertController: DDAlertController? { get }
  var stringsData: UpdatePopupStringsData { get set }
  
  func currentVersionLessThan(version: String) -> Bool
  func canShowRecommendedVersionAlert() -> Bool
  func startMonitoringForUpdates()
}

public class UpdatePopupImplementation: NSObject, UpdatePopupInterface {
  
  ///config data
  public var inputData: UpdatePopupInputData
    
  /// localized strings data
  public var stringsData: UpdatePopupStringsData

  /// Inject this property if you want a custom popup and set usesCustomAlert to true
  public var alertController: DDAlertController?
    
  /// Set this flag if you want a custom alert controller
  public var usesCustomAlert: Bool = false
  
  /// Service that is used to generate any application id so we can pass it to StoreKIt
  public let service: ItunesService
  
  /// Creates an instance with the specified params.
  ///
  /// - Note: App will crash if specifiying a value lower than 30 days for the interval.
  ///
  /// - Parameters: explained above
  public init(inputData: UpdatePopupInputData,
       stringsData: UpdatePopupStringsData,
       alertController: DDAlertController? = nil,
       service: ItunesService = ItunesServiceImplementation()) {
    
    if inputData.timeIntervalToShowAfterCancel < 30 {
      fatalError("TIME INTERVAL SHOULD BE A MINIMUM OF 30 DAYS")
    }
    
    self.stringsData = stringsData
    self.inputData = inputData
    self.alertController = alertController
    self.service = service
  }
  
  /// Call this method in order for update popup to start and listen for force or recommended updates.
  ///
  public func startMonitoringForUpdates() {
    if currentVersionLessThan(version: inputData.minVersion) {
      showForceUpdate()
      return
    }
    if currentVersionLessThan(version: inputData.recommendedVersion) {
        let lastShownPopupDate = UserDefaults.standard.object(forKey: updatePopupDateKey) as? Date
      if lastShownPopupDate == nil || canShowRecommendedVersionAlert() {
        showRecommendedUpdate()
      }
    }
  }
  
  /// Called on update button tap
  @objc func updateButtonAction() {
    LoadingIndicator.showSpinner()
    service.getItunesIdentifier(for: inputData.bundleId, completion: { [weak self] identifier in
      guard let self = self, let identifier = identifier else {
        DispatchQueue.main.async {
          LoadingIndicator.hideSpinner()
        }
        return
      }
        DispatchQueue.main.async {
          LoadingIndicator.hideSpinner()
          self.openStoreProductWithiTunesItemIdentifier(identifier)
      }
    })
  }
  
  /// Logic to check and compare the app version
  ///
  /// - Parameters: a version string
  public func currentVersionLessThan(version: String) -> Bool {
    let rdSplit = version.components(separatedBy: ".").map() { $0.integerValue }
    var localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    if localVersion.contains("-") {
      localVersion = localVersion.components(separatedBy: "-").first ?? ""
    }
    
    let localSplit = localVersion.components(separatedBy: ".").map() { $0.integerValue }
    
    guard rdSplit.count == 3,
          localSplit.count == rdSplit.count,
          rdSplit != localSplit
    else { return false }
    
    // From RD.
    let rmajor = rdSplit[0]
    let rminor = rdSplit[1]
    let rpatch = rdSplit[2]
    
    let major = localSplit[0]
    let minor = localSplit[1]
    let patch = localSplit[2]
    
    // 5.2.2 < 6.1.1
    guard major == rmajor else { return major < rmajor }
    // 5.1.2 < 5.2.1
    guard minor == rminor else { return minor < rminor }
    // 5.2.2 < 5.2.3
    return patch < rpatch
  }
  
  /// Logic to check if recommended popup can be shown
  ///
  public func canShowRecommendedVersionAlert() -> Bool {
      let lastPopupDate = UserDefaults.standard.object(forKey: updatePopupDateKey)
    let calendar = Calendar.current
    
    if let popupDate = lastPopupDate as? Date {
      let numberOfMinutes = calendar.dateComponents([.minute], from: popupDate, to: Date())
      let numberOfDays = calendar.dateComponents([.day], from: popupDate, to: Date())
      
      #if DEBUG
        return numberOfMinutes.minute! >= 10
      #else
      return numberOfDays.day! >= inputData.timeIntervalToShowAfterCancel
      #endif
    }
    
    return false
  }
}
