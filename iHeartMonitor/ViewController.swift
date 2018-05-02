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
    
    let beats: [String] = ["65", "80"]
    let cellReuseIdentifier = "heartrate"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
    }
    
    @IBAction func authorizeKitclicked(_ sender: Any) {
        self.authorizeHealthKitinApp()
    }
    
    @IBAction func getDetails(_ sender: Any) {
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
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beats.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.beats[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
}
