/*
See LICENSE folder for this sample’s licensing information.

Abstract:
THe workout session interface controller.
*/

import WatchKit
import Foundation
import HealthKit

class WorkoutSession: WKInterfaceController, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    //para las etiquetas en e storyboard bodyFatPercentage
    @IBOutlet weak var timer: WKInterfaceTimer!
    
    @IBOutlet weak var activeCaloriesLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var oxygenSaturationLabel: WKInterfaceLabel!
    @IBOutlet weak var bodyTemperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateVLabel: WKInterfaceLabel!
    @IBOutlet weak var fatLabel: WKInterfaceLabel!
    
    var healthStore: HKHealthStore!
    var configuration: HKWorkoutConfiguration!
    
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupWorkoutSessionInterface(with: context)
        
        // Create the session and obtain the workout builder. o sea se obtienen datos del usuario
        /// - Tag: CreateWorkout
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()
        } catch {
            dismiss()
            return
        }
        
        // Setup session and builder. (builder creo que es la persona)
        session.delegate = self
        builder.delegate = self
        
        /// Set the workout builder's data source. Se configura el data de la persona
        /// - Tag: SetDataSource
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)
        
        // Start the workout session and begin data collection.
        /// - Tag: StartSession
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
            self.setDurationTimerDate(.prepared)
        }
    }
    
    
    // Track elapsed time.
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Retreive the workout event.
        guard let workoutEventType = workoutBuilder.workoutEvents.last?.type else { return }
        
        // Update the timer based on the event received.
        switch workoutEventType {
        case .pause: // The user paused the workout.
            setDurationTimerDate(.paused)
        case .resume: // The user resumed the workout.
            setDurationTimerDate(.running)
        default:
            return
            
        }
    }
    
    func setDurationTimerDate(_ sessionState: HKWorkoutSessionState) {
        /// Obtain the elapsed time from the workout builder.
        /// - Tag: ObtainElapsedTime
        let timerDate = Date(timeInterval: -self.builder.elapsedTime, since: Date())
        
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            self.timer.setDate(timerDate)
        }
        
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            /// Update the timer based on the state we are in.
            /// - Tag: UpdateTimer
            sessionState == .prepared ? self.timer.start() : self.timer.stop()
        }
    }
    
    // MARK: - HKLiveWorkoutBuilderDelegate
    //se hace un sample, es decir como que datos leatorios creo
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            /// - Tag: GetStatistics
            let statistics = workoutBuilder.statistics(for: quantityType)
            let label = labelForQuantityType(quantityType)
            
            updateLabel(label, withStatistics: statistics)
        }
    }
    
    
    
    // MARK: - State Control
    func pauseWorkout() {
        session.pause()
    }
    
    func resumeWorkout() {
        session.resume()
    }
    
    func endWorkout() {
        /// Update the timer based on the state we are in.
        /// - Tag: SaveWorkout
        session.end()
        builder.endCollection(withEnd: Date()) { (success, error) in
            self.builder.finishWorkout { (workout, error) in
                // Dispatch to main, because we are updating the interface.
                DispatchQueue.main.async() {
                    self.dismiss()
                }
            }
        }
    }
    
    func setupWorkoutSessionInterface(with context: Any?) {
        guard let context = context as? WorkoutSessionContext else {
            dismiss()
            return
        }
        
        healthStore = context.healthStore
        configuration = context.configuration
        
        setupMenuItemsForWorkoutSessionState(.running)
    }
    
    /// Set up the contextual menu based on the workout session state.
    func setupMenuItemsForWorkoutSessionState(_ state: HKWorkoutSessionState) {
        clearAllMenuItems()
        if state == .running {
            addMenuItem(with: .pause, title: "Pause", action: #selector(pauseWorkoutAction))
        } else if state == .paused {
            addMenuItem(with: .resume, title: "Resume", action: #selector(resumeWorkoutAction))
        }
        addMenuItem(with: .decline, title: "End", action: #selector(endWorkoutAction))
    }
    
    /// Action for the "Pause" menu item.
    @objc
    func pauseWorkoutAction() {
        pauseWorkout()
    }
    
    /// Action for the "Resume" menu item.
    @objc
    func resumeWorkoutAction() {
        resumeWorkout()
    }
    
    /// Action for the "End" menu item.
    @objc
    func endWorkoutAction() {
        endWorkout()
    }
    
    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            self.setupMenuItemsForWorkoutSessionState(toState)
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // No error handling in this sample project.
    }
    
    // MARK: - Update the interface
    //super importante porque esto es lo que se medirá
    
    /// Retreive the WKInterfaceLabel object for the quantity types we are observing.
    
    //se assignan etiquetas en el storyboard para cada como funcion bodyFatPercentage
    func labelForQuantityType(_ type: HKQuantityType) -> WKInterfaceLabel? {
        switch type {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            return heartRateLabel
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            return activeCaloriesLabel
        case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
            return distanceLabel
            //aqui agregare los nuevos
        case HKQuantityType.quantityType(forIdentifier: .oxygenSaturation):
            return oxygenSaturationLabel
            
        case HKQuantityType.quantityType(forIdentifier: .bodyTemperature):
            return bodyTemperatureLabel
        
        case HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
            return heartRateVLabel
            
        case HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage):
                return fatLabel
            
        default:
            
            //bodyTemperatureLabel heartRateVLabel
            return nil
        }
    }
    
    /// Update the WKInterfaceLabels with new data.
    func updateLabel(_ label: WKInterfaceLabel?, withStatistics statistics: HKStatistics?) {
        // Make sure we got non `nil` parameters.
        guard let label = label, let statistics = statistics else {
            return
        }
        
        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                /// - Tag: SetLabel
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                label.setText("\(roundedValue) BPM")
                
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                let value = statistics.sumQuantity()?.doubleValue(for: energyUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                label.setText("\(roundedValue) cal")
                return
                
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                let value = statistics.sumQuantity()?.doubleValue(for: meterUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                label.setText("\(roundedValue) met")
                return
                
                //le quite que se dividiera entre minutos .bodyTemperature
            case HKQuantityType.quantityType(forIdentifier: .oxygenSaturation):
            let oxygenUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = statistics.mostRecentQuantity()?.doubleValue(for: oxygenUnit)
            let roundedValue = Double( round( 1 * value! ) / 1 )
            //aqui se indica que texto se le pondra a la etiqueta
            label.setText("\(roundedValue) SPO2 ")
                return
                
                
                //static let bodyTemperature: HKQuantityTypeIdentifier .heartRateVariabilitySDNN
            case HKQuantityType.quantityType(forIdentifier: .bodyTemperature):
            let temperatureUnit = HKUnit.degreeCelsius()
            let value = statistics.mostRecentQuantity()?.doubleValue(for: temperatureUnit)
            let roundedValue = Double( round( 1 * value! ) / 1 )
            //aqui se indica que texto se le pondra a la etiqueta
            label.setText("\(roundedValue) ºC ")
                return
            
            case HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
                               /// - Tag: SetLabel
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
            let roundedValue = Double( round( 1 * value! ) / 1 )
            label.setText("\(roundedValue) Bn")
                return
                
            case HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage):
                let fatUnit = HKUnit.fluidOunceUS().unitDivided(by: HKUnit.pound())
            let value = statistics.mostRecentQuantity()?.doubleValue(for: fatUnit)
            let roundedValue = Double( round( 1 * value! ) / 1 )
            //aqui se indica que texto se le pondra a la etiqueta
            label.setText("\(roundedValue) lb ")
                return
                
            default:
                return
                
            }
        }
    }
    
}
