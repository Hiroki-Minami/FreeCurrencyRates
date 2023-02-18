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
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    CurrencyNetworkController.shared.fetchListOfCurrnecy()
      .retry(when: { error in
        error.enumerated().flatMap { attemp, error -> Observable<Int> in
          if attemp >= 3 {
            return Observable.error(error)
          } else if let casted = error as? CurrencyNetworkController.CurrencyNetworkError, casted == .currenciesNotFound {
            return Observable.error(error)
          }
          
          print("== retrying after \(attemp + 5) seconds ==")
          return Observable<Int>.timer(.seconds(attemp + 5), scheduler: MainScheduler.instance)
            .take(1)
        }
      })
      .do(
        onError: { [weak self] error in
          self?.displayError(error)
        })
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
  
  func displayError(_ error: Error) {
    guard let _ = viewIfLoaded?.window else { return }
    var title: String
    
    if let error = error as? CurrencyNetworkController.CurrencyNetworkError {
      switch error {
      case .currenciesNotFound:
        title = "URL is invalid. Contact us."
      case .serverFailure:
        title = "Network issues happened. Try it again later."
      }
    } else {
      title = "An error occurred."
    }
    
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
