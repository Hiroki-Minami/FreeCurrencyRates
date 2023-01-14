//
//  ConversionFromBaseViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class ConversionFromBaseViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  
  var keys: [String] = []
  var conversionList: [String: Double] = [:]
  
  @IBOutlet var fromButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    // Do any additional setup after loading the view.d
    keys = Currency.shortNamesForCurrencies
    updateBaseUI()
  }
  
  func updateBaseUI() {
    let closure = { (action: UIAction) in
      self.fromButton.setTitle(action.title, for: .normal)
      Task {
        do {
          let conversions = try await CurrencyNetworkController.shared.fetchConversionFromBaseCurrency(currency: action.title)
          self.updateUI(with: conversions)
        } catch {
          self.displayError(error, title: "Getting Currencies Failed")
        }
      }
    }
    
    let actions = self.keys.map { str in
      UIAction(title: str, handler: closure)
    }
    fromButton.menu = UIMenu(children: actions)
    fromButton.showsMenuAsPrimaryAction = true
  }
  
  func updateUI(with conversions: [String: Double]) {
    self.conversionList = conversions
    self.tableView.reloadData()
  }
  
  func displayError(_ error: Error, title: String) {
    guard let _ = viewIfLoaded?.window else { return }
    
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}

extension ConversionFromBaseViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversionList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BaseToOthers", for: indexPath) as! BaseToOthersTableViewCell
    
    let key = keys[indexPath.row]
    
    cell.currencyTextLabel.text = key
    cell.rateTextLabel.text = String(conversionList[key]!)
    
    return cell
  }
}
