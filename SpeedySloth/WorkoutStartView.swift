/*
See LICENSE folder for this sample’s licensing information.

Abstract:
aqui esta la programacion de lo que evriamos
*/

import UIKit
import HealthKit

class WorkoutStartView: UIViewController {

    let healthStore = HKHealthStore()
    
    //aqui se esta cambiando la funcion heredada de UIviewController, configurando el titulo y la vista
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iHealthy"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!,
            HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKQuantityType.quantityType(forIdentifier: .height)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.workoutType()
           // HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error
            
        }
    }
    
}

