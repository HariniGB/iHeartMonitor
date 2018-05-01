//
//  HealthKitManager.swift
//  iHeartMonitorWatchApp Extension
//
//  Created by Harini Balakrishnan on 5/1/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    static let sharedInstance = HealthKitManager()
    
    private override init(){}
    
    let healthStore = HKHealthStore()
    
    func authorizeHealthKitinApp(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void))
    {
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let healthKitTypes = Set([
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            heartRateType,
            HKObjectType.workoutType(),
            ])
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            print("Error Occured!!!")
            return
        }
        
        healthStore.requestAuthorization(toShare: (healthKitTypes as! Set<HKSampleType>), read: healthKitTypes)
        {
            (success, error) -> Void in
            print("Was authorization successful? \(success)")
            completion(success, error)
        }
        
    }

    
}
