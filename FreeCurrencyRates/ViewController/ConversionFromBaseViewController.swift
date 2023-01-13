//
//  ConversionFromBaseViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class ConversionFromBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var conversionList: [String: Double] = [:]
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversionList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BaseToOthers", for: indexPath) as! BaseToOthersTableViewCell
    
    cell.currencyTextLabel.text = ""
    cell.rateTextLabel.text = ""
    
    return cell
  }
  

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
