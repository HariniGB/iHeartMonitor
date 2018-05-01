//
//  ViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 4/27/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
  
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblBloodgroup: UILabel!
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    var datasource: [String] = ["65", "80"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func authorizeKitclicked(_ sender: Any) {
        self.authorizeHealthKitinApp()
    }
    
    @IBAction func getDetails(_ sender: Any) {
        let (age, bloodtype) = self.readProfile()
        self.lblAge.text = String(describing: age!)
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
            age = currentyear - birthDay.year!
        }catch{}
        
        //        Read blood Type
        do{
            bloodType = try healthKitStore.bloodType()
        }catch{}
        return(age, bloodType)
    }
    
    func authorizeHealthKitinApp()
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
            return
        }
        
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead){ (success, error) -> Void in
            print("Was healthkit authorization successful? \(success)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath)
        print("the data is \(datasource[indexPath.row])")
        cell.textLabel?.text = datasource[indexPath.row]
        return cell
    }

}
