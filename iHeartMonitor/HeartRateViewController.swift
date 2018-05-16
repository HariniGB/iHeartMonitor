//
//  HeartRateViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/12/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import UIKit
import HealthKit
import Charts
import  UserNotifications

class HeartRateViewController: UIViewController {

    
    
    

    @IBOutlet weak var HeartRateLineChartView: LineChartView!
    
    var beats: [Double] = []
    let cellReuseIdentifier = "heartrate"
    var dataEntries: [ChartDataEntry] = []
    let heartRateUnit = HKUnit(from: "count/min")
    public let healthStore = HKHealthStore()
    
    // for heartrate query
    let health: HKHealthStore = HKHealthStore()
    //let heartRateUnit:HKUnit = HKUnit(from : "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let auth: Bool = self.authorizeHealthKitinApp()
        if auth == true {
            observerHeartRateSamples()
            updateChartData()
            
        } else {
            beats.removeAll()
            print("Unable to authorize HealthKit")
        }
        //Notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func authorizeHealthKitinApp() -> Bool
    {
        
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.workoutType(),
            ]
        
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            print("Error Occured!!!")
            return false
        }
        
       healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead){ (success, error) -> Void in
            print("Was healthkit authorization successful? \(success)")
        }
        
        return true
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
                    print("============================")
                    return
                }
//                DispatchQueue.main.async {
                    let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                    print("Heart Rate Sample: \(heartRate)")
                    self.beats.append(heartRate)
                    print("\(self.beats)")
//                }
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
    
    func updateChartData(){
//        this is the Array that will eventually display on th graph
//        let hearRateRange = [60, 70, 80, 90, 100]
//        let hourly = ["6.00 PM", "6.05 PM", "6.10 PM", "6.15 PM", "6.20 PM", "6.25 PM", "6.30 PM", "6.35 PM", "6.40 PM", "6.45 PM", "6.50 PM", "6.55 PM", "7.00 PM"]
//        let day = ["12 AM"," 1 AM","2 AM","3 AM","4 AM","5 AM","6 AM", "7 AM","8 AM","9 AM","10 AM", "11 AM", "12 PM"," 1 PM","2 PM","3 PM","4 PM","5 PM","6 PM", "7 PM","8 PM","9 PM","10 PM", "11 PM" ]
//        let week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let month = ["Week 1", "Week 2", "Week 3", "Week 4"]
//        let year = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "July","Aug", "Sep", "Nov", "Dec"]
        
//   here is the for loop to calcualte the X axis and Y axis
        
        for i in 0..<month.count{
            print(self.beats)
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(i))
            self.dataEntries.append(dataEntry)
        }
        
   //        Here we convert linechartEntry to a LineChartDataSet
        let line1 = LineChartDataSet(values: self.dataEntries, label: "Number")
        
   //  Sets the colour to blue
        line1.colors = [NSUIColor.blue]

   //   This is the object that will be added to the chart
        let data = LineChartData(dataSet: line1)
    
//        finally = its adds the chart data to the chart and causes an update
       HeartRateLineChartView.data = data
        
//        Here we set the tile for the graph
        HeartRateLineChartView.chartDescription?.text = "HeartRate Chart"
    }
    
    
    
    
    @IBAction func HeartRateNotification(_ sender: Any) {
        
        getAVGHeartRate{ (beats) in
            //Notify
            
            for ibeats in beats{
                
                switch true{
                case ibeats < 60.00:
                    //print ("less")
                    
                    
                    let content = UNMutableNotificationContent()
                    
                    //adding title, subtitle, body and badge
                    content.title = "Alert"
                    content.subtitle = "Abnormality in heart beat reported"
                    content.body = "Your heart beat patterns is seem abnormal, if this is not the first time you are seeing this, probably a good time to get a physical"
                    content.badge = 1
                    
                    //getting the notification trigger
                    //it will be called after 5 seconds
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    
                    //getting the notification request
                    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
                    
                    //adding the notification to notification center
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                case ibeats > 100.00:
                    //print ("more")
                    
                    
                    let content = UNMutableNotificationContent()
                    
                    //adding title, subtitle, body and badge
                    content.title = "Alert"
                    content.subtitle = "Abnormality in heart beat reported"
                    content.body = "Your heart beat patterns is seem abnormal, if this is not the first time you are seeing this, probably a good time to get a physical"
                    content.badge = 1
                    
                    //getting the notification trigger
                    //it will be called after 5 seconds
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    
                    //getting the notification request
                    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
                    
                    //foreground noti (remove this to make backgroung notification)
                    UNUserNotificationCenter.current().delegate = (self as! UNUserNotificationCenterDelegate)
                    
                    //adding the notification to notification center
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                default:
                    //print("Normal")
                    
                    let content = UNMutableNotificationContent()
                    
                    //adding title, subtitle, body and badge
                    content.title = "Normal"
                    content.subtitle = "Heart Beat Patterns"
                    content.body = ""
                    content.badge = 1
                    
                    //getting the notification trigger
                    //it will be called after 5 seconds
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    
                    //getting the notification request
                    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
                    
                    //adding the notification to notification center
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                
            }// Heart rate notification end
            
        }
                
    }
    
    
    //Function to find average heart rate
    func getAVGHeartRate(completion: @escaping (_ array: [Double]) -> Void) {
        
        let typeHeart = HKQuantityType.quantityType(forIdentifier: .heartRate)
        let startDate = Date() - 7 * 24 * 60 * 60 // start date is a week
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: HKQueryOptions.strictEndDate)
        
        let squery = HKStatisticsQuery(quantityType: typeHeart!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                let quantity: HKQuantity? = result?.averageQuantity()
                var _: Double? = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
               //print("got")
            })
        })
        healthStore.execute(squery)
    }
        
        
        
    

    
    //step function notification
    @IBAction func getTodaysSteps(_ sender: Any) {
        
        getTodaysSteps { (result) in
            print("\(result)")
            DispatchQueue.main.async {
                //self.totalSteps.text = "\(result)"
                
                if result < 500 {
                    let content = UNMutableNotificationContent()
                    
                    //adding title, subtitle, body and badge
                    content.title = "Alert"
                    content.subtitle = "Less Activity"
                    content.body = "Please go out for a walk"
                    content.badge = 1
                    
                    //getting the notification trigger
                    //it will be called after 5 seconds
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    
                    //getting the notification request
                    let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
                    
                    //foreground notification (remove this to make backgroung notification)
                    UNUserNotificationCenter.current().delegate = ( self as? UNUserNotificationCenterDelegate)
                    
                    //adding the notification to notification center
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                   
                }
            }
        }
    }
    
    
    //step function
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            guard let result = result else {
                print("Failed to fetch steps rate")
                completion(resultCount)
                return
            }
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
                completion(resultCount)
            }
        }
        healthStore.execute(query)
         //print("sucess")
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

