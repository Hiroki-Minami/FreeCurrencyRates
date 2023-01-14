//
//  ConversionFromBaseViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class ConversionFromBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var tableView: UITableView!
  
  var keys: [String] = []
  var conversionList: [String: String] = [:]
  var fromCurrency: String?
  
  @IBOutlet var fromButton: UIButton!
  
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
    tableView.delegate = self
    tableView.dataSource = self
    // Do any additional setup after loading the view.
    Task {
      do {
        let currencies = try await CurrencyNetworkController.shared.fetchListOfCurrnecy()
        updateBaseUI(with: currencies)

      } catch {
        displayError(error, title: "Getting Currencies Failed")
      }
    }
  }
  
  func updateBaseUI(with currencies: [String: String]) {
    self.keys = currencies.keys.sorted(by: {$0 < $1})
    
    let closure = { (action: UIAction) in
      self.fromCurrency = action.title
      self.fromButton.setTitle(action.title, for: .normal)
      Task {
        do {
          let currencies = try await CurrencyNetworkController.shared.fetchConversionFromBaseCurrency(currency: self.fromCurrency!)
          self.updateUI(with: currencies)
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
  
  func updateUI(with currencies: [String: String]) {
    self.conversionList = currencies
    self.keys = currencies.keys.sorted(by: {$0 < $1})
    self.tableView.reloadData()
  }
  
  func displayError(_ error: Error, title: String) {
    guard let _ = viewIfLoaded?.window else { return }
    
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
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
