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
    
    var beats: [String] = []
    let cellReuseIdentifier = "heartrate"
    let heartRateUnit = HKUnit(from: "count/min")
    public let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let auth: Bool = self.authorizeHealthKitinApp()
        if auth == true {
            self.getDetails()
            observerHeartRateSamples()
        } else {
            beats.removeAll()
            beats.append("Unable to authorize HealthKit")
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
        self.tableView.dataSource = self
    }
    
    
    
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
    
    func observerHeartRateSamples() {
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
        
        let observerQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestHeartRateSample { (sample) in
                guard let sample = sample else {
                    return
                }
                
                DispatchQueue.main.async {
                    let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                    print("Heart Rate Sample: \(heartRate)")
                    self.beats.append("\(heartRate)")
                    self.tableView.reloadData()
                    print("\(self.beats)")
                }
            }
        }
        
        healthStore.execute(observerQuery)
    }
    
    func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
        }
        
        healthStore.execute(query)
    }
    
    
    
}
