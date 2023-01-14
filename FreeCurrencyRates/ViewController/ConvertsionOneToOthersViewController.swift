//
//  ConvertsionOneToAnotherViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class ConvertsionOneToOthersViewController: UIViewController {

  var keys: [String] = []
  
  @IBOutlet var conversionLabel: UILabel!
  
  @IBOutlet var fromButton: UIButton!
  @IBOutlet var toButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    keys = Currency.shortNamesForCurrencies
    updateBaseUI()
  }
  
  func updateBaseUI() {
    let fromClosure = setUpClosure(targetButton: fromButton, anothorButton: toButton, anotherButtonTitle: "To")
    let toClosure = setUpClosure(targetButton: toButton, anothorButton: fromButton, anotherButtonTitle: "From")
    
    let fromActions = self.keys.map { str in
      UIAction(title: str, handler: fromClosure)
    }
    let toActions = self.keys.map { str in
      UIAction(title: str, handler: toClosure)
    }
    fromButton.menu = UIMenu(children: fromActions)
    fromButton.showsMenuAsPrimaryAction = true
    
    toButton.menu = UIMenu(children: toActions)
    toButton.showsMenuAsPrimaryAction = true
  }
  
  func setUpClosure(targetButton: UIButton, anothorButton: UIButton, anotherButtonTitle: String) -> (_ action: UIAction) -> ()  {
    let closure = { (action: UIAction) in
      targetButton.setTitle(action.title, for: .normal)
      if let title = anothorButton.titleLabel!.text, title != anotherButtonTitle {
        Task {
          do {
            let conversions = try await CurrencyNetworkController.shared.fetchConversionFromOneToAnother(from: anothorButton.titleLabel!.text!, to: action.title)
            self.updateUI(with: conversions)
          } catch {
            self.displayError(error, title: "Getting Currencies Failed")
          }
        }
      }
    }
    return closure
  }
  
  func updateUI(with conversion: Double) {
    self.conversionLabel.text = String(conversion)
  }
  
  func displayError(_ error: Error, title: String) {
    guard let _ = viewIfLoaded?.window else { return }
    
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
}
