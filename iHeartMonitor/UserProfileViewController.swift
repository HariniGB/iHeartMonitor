//
//  UserProfileViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/12/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import UIKit
import HealthKit
import FirebaseAuth
import UserNotifications





class UserProfileViewController: UIViewController {
    
    
//logout
    @IBAction func Logout(_ sender: Any) {
        
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! UINavigationController
            self.present(vc, animated: false, completion: nil)
        }
       
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let auth: Bool = self.authorizeHealthKitinApp()
        if auth == true {
            self.getDetails()
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    //
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblBloodgroup: UILabel!
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    public let healthStore = HKHealthStore()
    
    func getDetails() {
        let username = UIDevice.current.name
//      let username = Auth.auth().currentUser?.displayName
        print("User name is \(String(describing: username))")
        let (age, bloodtype, gender) = self.readProfile()
                if !username.isEmpty {
                    self.lblName.text = username
                } else {
                    self.lblName.text = "User Details"
                }
        if age != nil {
            self.lblAge.text = String(describing: age!)
        } else {
            self.lblAge.text = "unknown"
        }
        if gender != nil  {
            switch gender?.biologicalSex {
            case .female?:
                self.lblGender.text =  "Female"
            case .male?:
                self.lblGender.text =  "Male"
            case .none:
                self.lblGender.text =  "unknown"
            case .some(.notSet):
                self.lblGender.text =  "unknown"
            case .some(.other):
                self.lblGender.text =  "unknown"
            }
        } else {
            self.lblGender.text = "unknown"
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
    
    
    func readProfile() -> ( age:Int?, bloodtype:HKBloodTypeObject?,  gender:HKBiologicalSexObject?){
        //        var name:String?
        var age:Int?
        var bloodType:HKBloodTypeObject?
        var gender:HKBiologicalSexObject?
        
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
        //        Read Gender Type
        do{
            gender = try healthKitStore.biologicalSex()
        }catch{
            print("Error info: \(error)")
        }
        return(age, bloodType, gender)
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
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            
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
    
    
    func getMostRecentSample(for sampleType: HKSampleType,
                             completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(mostRecentSample, nil)
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    func loadAndDisplayMostRecentWeight(){
        //1. Use HealthKit to create the Height Sample Type
        guard let height = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        self.getMostRecentSample(for: height) {
            (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    print("Error info: \(error)")
                }
                return
            }
            
            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            print("Height is: \(heightInMeters)")
            self.lblHeight.text = String(describing: heightInMeters)
        }
        
        guard let weight = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
        
        self.getMostRecentSample(for: weight) {
            (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    print("Error info: \(error)")
                }
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            print("Weight is: \(weightInKilograms)")
            self.lblWeight.text = String(describing: weightInKilograms)
        }
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
