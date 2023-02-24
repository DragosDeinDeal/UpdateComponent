//
//  ItunesService.swift
//  DeinDeal
//
//  Created by Dragos Marinescu on 16.02.2023.
//  Copyright © 2023 Goodshine AG. All rights reserved.
//

import Foundation

public protocol ItunesService {
  func getItunesIdentifier(for bundleId: String?, completion: @escaping ((String?) -> Void))
}

public class ItunesServiceImplementation: ItunesService {
    
  public init() {}
    
  public func getItunesIdentifier(for bundleId: String?, completion: @escaping ((String?) -> Void)) {
    var mainBundleId = Bundle.main.bundleIdentifier
    
    if let bundleId = bundleId {
      mainBundleId = bundleId
    }
    
    if let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(mainBundleId ?? "")") {
      URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
        
        guard let data = data else {
          completion(nil)
          return
        }
      
      let infoDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
      if let info = infoDictionary {
        let result = (info["results"] as? [Any])?.first as? [String: Any]
        let appITunesItemIdentifier = result?["trackId"] as? Int

        completion(String(appITunesItemIdentifier ?? 0))
      }
      }.resume()
    }
  }
}
