//
//  UserProfileViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/12/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import UIKit
import HealthKit

class UserProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let auth: Bool = self.authorizeHealthKitinApp()
        if auth == true {
            self.getDetails()
           
        } else {
            beats.removeAll()
            beats.append("Unable to authorize HealthKit")
        }
       
    }
    
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblBloodgroup: UILabel!
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    var beats: [String] = []
    let cellReuseIdentifier = "heartrate"
    let heartRateUnit = HKUnit(from: "count/min")
    public let healthStore = HKHealthStore()
    
    func getDetails() {
        let (age, bloodtype) = self.readProfile()
        if age != nil {
            self.lblAge.text = String(describing: age!)
        } else {
            self.lblAge.text = "unknown"
        }
        
        print("blood type: \(self.getReadablebloodType(bloodType: bloodtype?.bloodType))")
        
        self.lblBloodgroup.text = self.getReadablebloodType(bloodType: bloodtype?.bloodType)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getReadablebloodType(bloodType:HKBloodType?)->String
    {
        var bloodTypeText = "";
        
        if bloodType != nil {
            switch( bloodType! ) {
            case .aPositive:
                bloodTypeText = "A+"
            case .aNegative:
                bloodTypeText = "A-"
            case .bPositive:
                bloodTypeText = "B+"
            case .bNegative:
                bloodTypeText = "B+"
            case .abPositive:
                bloodTypeText = "AB+"
            case .abNegative:
                bloodTypeText = "AB-"
            case .oPositive:
                bloodTypeText = "O+"
            case .oNegative:
                bloodTypeText = "O-"
            default:
                break;
            }
        }
        return bloodTypeText;
    }
    
    
    func readProfile() -> ( age:Int?, bloodtype:HKBloodTypeObject?){
        var age:Int?
        var bloodType:HKBloodTypeObject?
        
        //        Read Age
        do{
            let birthDay = try healthKitStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentyear = calendar.component(.year, from: Date())
            let currentmonth = calendar.component(.month, from: Date())
            
            age = currentyear - birthDay.year!
            if currentmonth < birthDay.month! {
                age = age! - 1
            }
            
        }catch{
            print("Error info: \(error)")
        }
        
        //        Read blood Type
        do{
            bloodType = try healthKitStore.bloodType()
        }catch{
            print("Error info: \(error)")
        }
        
        return(age, bloodType)
    }
    
    func authorizeHealthKitinApp() -> Bool
    {
        
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.workoutType(),
            ]
        
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            print("Error Occured!!!")
            return false
        }
        
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead){ (success, error) -> Void in
            print("Was healthkit authorization successful? \(success)")
        }
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
