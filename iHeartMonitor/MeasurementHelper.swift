//
//  MeasurementHelper.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/15/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import Foundation
import Firebase

class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
        Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
         Analytics.logEvent("logout", parameters: nil)
    }
    
    static func sendMessageEvent() {
        Analytics.logEvent("message", parameters: nil)
    }
}
