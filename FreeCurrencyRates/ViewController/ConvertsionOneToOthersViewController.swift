//
//  ConvertsionOneToAnotherViewController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class ConvertsionOneToOthersViewController: UIViewController {
  
  var conversion: Double?
  var keys: [String] = []
  
  @IBOutlet var conversionLabel: UILabel!
  
  @IBOutlet var fromButton: UIButton!
  @IBOutlet var toButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
      self.fromButton.setTitle(action.title, for: .normal)
      if let title = self.toButton.titleLabel!.text, title != "To" {
        Task {
          do {
            let conversions = try await CurrencyNetworkController.shared.fetchConversionFromOneToAnother(from: action.title, to: self.toButton.titleLabel!.text!)
            self.updateUI(with: conversions)
          } catch {
            self.displayError(error, title: "Getting Currencies Failed")
          }
        }
      }
    }
    
    let closure2 = { (action: UIAction) in
      self.toButton.setTitle(action.title, for: .normal)
      if let title = self.fromButton.titleLabel!.text, title != "From" {
        Task {
          do {
            let conversions = try await CurrencyNetworkController.shared.fetchConversionFromOneToAnother(from: self.fromButton.titleLabel!.text!, to: action.title)
            self.updateUI(with: conversions)
          } catch {
            self.displayError(error, title: "Getting Currencies Failed")
          }
        }
      }
    }
    
    let actions = self.keys.map { str in
      UIAction(title: str, handler: closure)
    }
    
    let actions2 = self.keys.map { str in
      UIAction(title: str, handler: closure2)
    }
    fromButton.menu = UIMenu(children: actions)
    fromButton.showsMenuAsPrimaryAction = true
    
    toButton.menu = UIMenu(children: actions2)
    toButton.showsMenuAsPrimaryAction = true
  }
  
  func updateUI(with conversion: Double) {
    self.conversion = conversion
    self.conversionLabel.text = String(conversion)
  }
  
  func displayError(_ error: Error, title: String) {
    guard let _ = viewIfLoaded?.window else { return }
    
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
}
