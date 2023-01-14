//
//  CurrenciesTableViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class CurrenciesTableViewController: UITableViewController {
  
  var keys: [String] = []
  var currencies: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Task {
      do {
        let currencies = try await CurrencyNetworkController.shared.fetchListOfCurrnecy()
        Currency.currencies = currencies
        updateUI(with: currencies)
      } catch {
        displayError(error, title: "Getting Currencies Failed")
      }
    }
  }
  
  func updateUI(with currencies: [String: String]) {
    self.currencies = currencies
    self.keys = currencies.keys.sorted(by: {$0 < $1})
    self.tableView.reloadData()
  }
  
  func displayError(_ error: Error, title: String) {
    guard let _ = viewIfLoaded?.window else { return }
    
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return currencies.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Currencies", for: indexPath) as! CurrenciesTableViewCell
    
    // Configure the cell...
    let short = keys[indexPath.row]
    let long = self.currencies[keys[indexPath.row]]
    cell.shortNameTextLabel.text = short
    cell.fullNameTextLabel.text = long
    
    return cell
  }
}
