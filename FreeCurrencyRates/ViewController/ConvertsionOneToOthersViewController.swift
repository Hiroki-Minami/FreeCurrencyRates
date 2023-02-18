//
//  ConvertsionOneToAnotherViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit
import RxSwift
import RxCocoa

class ConvertsionOneToOthersViewController: UIViewController {

  var keys: [String] = []
  
  @IBOutlet var conversionLabel: UILabel!
  
  @IBOutlet var fromButton: UIButton!
  @IBOutlet var toButton: UIButton!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    keys = Currency.shortNamesForCurrencies
    updateBaseUI()
  }
  
  func updateBaseUI() {
    let fromClosure = setUpClosure(targetButton: fromButton, anothorButton: toButton, anotherButtonTitle: "To")
    let fromActions = self.keys.map { str in
      UIAction(title: str, handler: fromClosure)
    }
    fromButton.menu = UIMenu(children: fromActions)
    fromButton.showsMenuAsPrimaryAction = true
    
    let toClosure = setUpClosure(targetButton: toButton, anothorButton: fromButton, anotherButtonTitle: "From")
    let toActions = self.keys.map { str in
      UIAction(title: str, handler: toClosure)
    }
    toButton.menu = UIMenu(children: toActions)
    toButton.showsMenuAsPrimaryAction = true
  }
  
  func setUpClosure(targetButton: UIButton, anothorButton: UIButton, anotherButtonTitle: String) -> (_ action: UIAction) -> ()  {
    let closure = { (action: UIAction) in
      targetButton.setTitle(action.title, for: .normal)
      if let title = anothorButton.titleLabel!.text, title != anotherButtonTitle {
        CurrencyNetworkController.shared.fetchConversionFromOneToAnother(from: anothorButton.titleLabel!.text!, to: action.title)
        
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
            .catchAndReturn(-1.0)
          .filter { $0 > 0 }
          .map({ conversion in
            return String(conversion)
          })
          .bind(to: self.conversionLabel.rx.text)
          .disposed(by: self.disposeBag)
      }
    }
    return closure
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
}
