//
//  TheBasicsViewController.swift
//  SpeedySloth
//
//  Created by Lía Michelle on 09/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class TheBasicsViewController: UIViewController {

    
     @IBOutlet weak var Age: UITextField!
     @IBOutlet weak var Height: UITextField!
     @IBOutlet weak var Weight: UITextField!
   
    var ageInt = 0
    var heightInt = 0.0
    var weightInt = 0.0
    var covidPercentage = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }
    
    func bmiCalculator() -> Int {
        ageInt = Int(Age.text!) ?? 0
        heightInt = Double(Height.text!) ?? 0
        weightInt = Double(Weight.text!) ?? 0
        
        let bmi = weightInt/(heightInt*heightInt)
        if bmi < 18.5 {
            covidPercentage = 4
            print(covidPercentage, "Funcionaaaaa")
        }
        else if bmi >= 18.5 && bmi < 25 {
            covidPercentage = 0
            print(covidPercentage, "Funcionaaaaa")
        }
        else {
            covidPercentage = 7
            print(covidPercentage, "Funcionaaaaa")
        }
        return covidPercentage
    }
 
    func yearsOld() -> Int {
        if ageInt < 50 {
            covidPercentage = 0
            print(covidPercentage, "Funcionaaaaa")
        }
        else {
            covidPercentage = 50
            print(covidPercentage, "Funcionaaaaa")
        }
        return covidPercentage
    }
    
        
 
    

    
    
    
    
    @IBAction func nextBasics(_ sender: UIButton) {
        
        
    }
    
    

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
