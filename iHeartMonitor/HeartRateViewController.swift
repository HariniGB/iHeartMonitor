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

class HeartRateViewController: UIViewController {


    @IBOutlet weak var HeartRateLineChartView: LineChartView!
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    var beats: [Double] = []
    let cellReuseIdentifier = "heartrate"
    let heartRateUnit = HKUnit(from: "count/min")
    public let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let auth: Bool = self.authorizeHealthKitinApp()
        if auth == true {
            observerHeartRateSamples()
        } else {
            beats.removeAll()
            print("Unable to authorize HealthKit")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    self.beats.append(heartRate)
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
    
    func updateChartData(){
        
//        this is the Array that will eventually display on th graph
        var lineChartEntry = [ChartDataEntry]()
        
//   here is the for loop to calcualte the X axis and Y axis
        for i in 40..<140 {
            for j in 0..<self.beats.count {
                let value = ChartDataEntry(x: Double(i), y: self.beats[j])
                 lineChartEntry.append(value);
            }
        }
   //        Here we convert linechartEntry to a LineChartDataSet
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number")

   //  Sets the colour to blue
        line1.colors = [NSUIColor.blue]
        
   //   This is the object that will be added to the chart
        let data = LineChartData()
        
//        Adds the line to the dataset
        data.addDataSet(line1);
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
