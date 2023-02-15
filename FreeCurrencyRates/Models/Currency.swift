//
//  Currency.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import Foundation

struct Currency {
  typealias CurrencyType = [String: String]
  typealias ConversionFromBaseCurrency = [String: Double]
  typealias ConversionFromOneToAnother = Double
  
  static var currencies: [String: String] = [:] {
    didSet {
      self.shortNamesForCurrencies = currencies.keys.sorted(by: {$0 < $1})
    }
  }
  static private(set) var shortNamesForCurrencies: [String] = []
}
