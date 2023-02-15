//
//  CurrenciesTableViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit
import RxSwift
import RxCocoa

class CurrenciesTableViewController: UITableViewController {
  
  var keys: [String] = []
  var currencies: [String: String] = [:]
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    CurrencyNetworkController.shared.fetchListOfCurrnecy()
      .catchAndReturn([:])
      .filter { $0.count > 0 }
      .subscribe(onNext: {[weak self] in
        Currency.currencies = $0
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      })
      .disposed(by: disposeBag)
  }
  
  func displayError(_ error: Error, title: String) {
    guard let _ = viewIfLoaded?.window else { return }
    
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Currency.currencies.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Currencies", for: indexPath) as! CurrenciesTableViewCell
    
    let short = Currency.shortNamesForCurrencies[indexPath.row]
    let long = Currency.currencies[short]
    cell.shortNameTextLabel.text = short
    cell.fullNameTextLabel.text = long
    
    return cell
  }
}
