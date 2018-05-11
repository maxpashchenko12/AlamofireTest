//
//  ViewController.swift
//  Spiner
//
//  Created by Max on 20.10.17.
//  Copyright © 2017 Max. All rights reserved.
//

import UIKit
import Alamofire

let requestURLPairs = "https://api.cryptowat.ch/pairs"
var requestURLExchanges = ""
var requestURLMarketPrice = ""

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerPair: UIPickerView!
    @IBOutlet weak var pickerExchanger: UIPickerView!
    @IBOutlet weak var marketPrice: UILabel!
    
    var pairsArray = Array<NSDictionary>()
    var exchangersArray = Array<NSDictionary>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(requestURLPairs).responseJSON { (response) in
            switch response.result {
            case .success(_):
                print(response)
                if let JSONPairs = response.result.value as? NSDictionary {
                    self.pairsArray = (JSONPairs["result"] as? Array)!
                    print(JSONPairs)
                    self.pickerPair.reloadAllComponents()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        pickerPair.dataSource = self
        pickerPair.delegate = self
        
        pickerExchanger.dataSource = self
        pickerExchanger.delegate = self
        
    }
    
    
    var name = String()
    var exchange = String()
    var price = String()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.view.viewWithTag(1) {
            return pairsArray.count
        } else if pickerView == self.view.viewWithTag(2) {
            return exchangersArray.count
        }
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.view.viewWithTag(1) {
            if let element = self.pairsArray[row] as? [String:Any] {
                let subelementOne = element["base"] as? NSDictionary
                var firstID = subelementOne!["id"] as! String
                let slash:String = " / "
                firstID.append(slash)

                let subelementTwo = element["quote"] as? NSDictionary
                let secondID = subelementTwo!["id"] as! String
                name = firstID.uppercased() + secondID.uppercased()
            }
            return name

        } else if pickerView == self.view.viewWithTag(2) {
            let element = self.exchangersArray[row]
            exchange = element["exchange"] as! String
            
            }
        return exchange
        
    }
        
    
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        
        if pickerView == self.view.viewWithTag(1) {
            print(row)
            
            let pairData = self.pairsArray[row]
            let pairRoute = pairData["route"] as? String
            
            Alamofire.request(pairRoute!).responseJSON { (response) in
                switch response.result {
                case .success(_):
                    print(response)
                    if let JSONExchanges = response.result.value as? NSDictionary {
                        let result = (JSONExchanges["result"] as? NSDictionary)
                        if let markets = result!["markets"] as? [NSDictionary]{
                            self.exchangersArray = markets
                        }
                        
                        print(JSONExchanges)
                        
                        self.pickerExchanger.reloadAllComponents()
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        } else if pickerView == self.view.viewWithTag(2) {
            
       
            let priceData = self.exchangersArray[row]
            let route = priceData["route"] as? String
            let priceRoute = route! + "/price"
            
            Alamofire.request(priceRoute).responseJSON { (response) in
                switch response.result {
                case .success(_):
                    print(response)
                    if let JSONPrice = response.result.value as? NSDictionary {
                        let result = (JSONPrice["result"] as? NSDictionary)
                        if let price = result!["price"] as? Double {
//                            self.pricesArray = price
                            print(price)
                            self.marketPrice.text =  ("Цена пары:\(self.name) на обменнике \(self.exchange) равна\(price)")
                            }
                         print(JSONPrice)
                        self.marketPrice.reloadInputViews()
                        }

                case .failure(let error):
                    print(error)
                }
              }
            }
       

    }
}

    
    
    


        
        
        
     
           
 


