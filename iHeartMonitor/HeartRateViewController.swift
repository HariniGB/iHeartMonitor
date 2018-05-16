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
import FirebaseAuth

class HeartRateViewController: UIViewController {


    @IBOutlet weak var HeartRateLineChartView: LineChartView!
    
    var beats: [Double] = []
    let cellReuseIdentifier = "heartrate"
    var dataEntries: [ChartDataEntry] = []
    let heartRateUnit = HKUnit(from: "count/min")
    public let healthStore = HKHealthStore()
    
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func Logout(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondViewController = storyboard.instantiateViewController(withIdentifier: "HomePage") as UIViewController
             self.present(secondViewController, animated: true, completion: nil)
        } catch {
            print("Problem loggin out")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
