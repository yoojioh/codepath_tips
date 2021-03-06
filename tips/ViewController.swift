//
//  ViewController.swift
//  tips
//
//  Created by Ji Oh Yoo on 1/14/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var percLabel: UILabel!
    
    var postTaxMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        billField.becomeFirstResponder()
//        loadValues()
//        updateFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTap(sender: UITapGestureRecognizer) {
        // view.endEditing(true)
    }
    
    @IBAction func onPan(sender: UIPanGestureRecognizer) {
        let velocity: CGPoint = sender.velocityInView(view)
        print(velocity, velocity.x)
        if CGFloat.abs(velocity.x) > 50 {
            var steps = Int(CGFloat.abs(velocity.x) / 100)
            if steps == 0 {
                steps = 1
            }
            let percLabelString = percLabel.text!
            var tipPerc = Double(percLabelString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "%")))!
            if velocity.x > 0 {
                tipPerc += 0.1 * Double(steps)
            } else {
                tipPerc -= 0.1 * Double(steps)
            }
            
            if tipPerc > 100.0 {
                tipPerc = 100.0
            } else if tipPerc < 0.0 {
                tipPerc = 0.0
            }
            
            percLabel.text = String(tipPerc) + "%"
            updateFields()
        }
        tipControl.tintColor = UIColor.grayColor()
    }
    
    @IBAction func onEditingChanged(sender: UITextField) {
        let text = billField.text?.stringByReplacingOccurrencesOfString(".", withString: "") ?? ""
        let amount = Double.init(text) ?? 0.0

        billField.text = String(format: "%.2f", amount / 100.0)
        updateFields()
    }
    
    @IBAction func onValueChanged(sender: AnyObject) {
        let percString = tipControl.titleForSegmentAtIndex(tipControl.selectedSegmentIndex) ?? "20%"
        let perc = Int(percString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "%")))!
        percLabel.text = String(perc) + ".0%"
        tipControl.tintColor = nil
        updateFields()
    }
    
    
    @IBAction func updateFields() {
        var billAmountDouble = 0.0
        if billField.text != nil && Double.init(billField.text!) != nil {
            billAmountDouble = Double.init(billField.text!)!
        }
        
        let percLabelString = percLabel.text!
        let tipRate = Double(percLabelString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "%")))! / 100.0
        
        var tip = 0.0
        if postTaxMode {
            tip = billAmountDouble * tipRate
        } else {
            tip = billAmountDouble / 1.0775 * tipRate
        }
        let total = billAmountDouble + tip

        tipLabel.text = String(format: "$%.2f", tip)
        totalLabel.text = String(format: "$%.2f", total)
        saveValues()
    }
    
    func loadValues() {
        let defaults = NSUserDefaults.standardUserDefaults()
        billField.text = defaults.objectForKey("billFieldText") as? String ?? "0.00"
        tipControl.selectedSegmentIndex = defaults.objectForKey("tipControlSelectedSegmentIndex") as? Int ?? 1
        percLabel.text = defaults.objectForKey("percLabelText") as? String ?? "20.0%"
        
        // Settings values
        tipControl.setTitle(String(defaults.valueForKey("minPerc") as? Int ?? 15) + "%", forSegmentAtIndex: 0)
        tipControl.setTitle(String(defaults.valueForKey("defaultPerc") as? Int ?? 20) + "%", forSegmentAtIndex: 1)
        tipControl.setTitle(String(defaults.valueForKey("maxPerc") as? Int ?? 25) + "%", forSegmentAtIndex: 2)
        postTaxMode = defaults.valueForKey("posttax") as? Bool ?? true
        
        let isColorGray = defaults.boolForKey("tipControlTintColorIsGray") ?? false
        if isColorGray {
            tipControl.tintColor = UIColor.grayColor()
        } else {
            tipControl.tintColor = nil
            let percString = tipControl.titleForSegmentAtIndex(tipControl.selectedSegmentIndex) ?? "20%"
            let perc = Int(percString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "%")))!
            percLabel.text = String(perc) + ".0%"
        }
    }
    
    func saveValues() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "hasValues")
        defaults.setObject(billField.text, forKey: "billFieldText")
        print(tipControl.tintColor)
        defaults.setBool(tipControl.tintColor == UIColor.grayColor(), forKey: "tipControlTintColorIsGray")
        
        defaults.setInteger(tipControl.selectedSegmentIndex, forKey: "tipControlSelectedSegmentIndex")
        defaults.setObject(percLabel.text, forKey: "percLabelText")
        defaults.synchronize()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        billField.becomeFirstResponder()
        loadValues()
        updateFields()
    }
}

