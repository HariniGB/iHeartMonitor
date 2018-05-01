//
//  InterfaceController.swift
//  iHeartMonitorWatchApp Extension
//
//  Created by Harini Balakrishnan on 5/1/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController {

    let healthKitManager = HealthKitManager.sharedInstance
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        healthKitManager.authorizeHealthKitinApp{
            (success, error) in
            print("Was healthkit successful? \(success)")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
