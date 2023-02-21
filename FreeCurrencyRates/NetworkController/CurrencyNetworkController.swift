//
//  CurrencyNetworkController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import Foundation
import RxSwift
import RxCocoa

struct CurrencyNetworkController {
  static let baseURL = URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/")!
  static let shared = CurrencyNetworkController()
  
  private init() {}
  
  func fetchListOfCurrnecy() -> Observable<Currency.CurrencyType> {
    let request = URLRequest(url: Self.baseURL.appendingPathComponent("currencies.json"))
    return URLSession.shared.rx.data(request: request)
      .map { data in
        try JSONDecoder().decode(Currency.CurrencyType.self, from: data)
      }
  }
  
  func fetchConversionFromBaseCurrency(currency: String) -> Observable<Currency.ConversionFromBaseCurrency> {
    let request = URLRequest(url: Self.baseURL.appendingPathComponent("currencies/\(currency).json"))
    return URLSession.shared.rx.data(request: request)
      .map { [currency] data in
        let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
        return convertedDataArray[currency] as! Currency.ConversionFromBaseCurrency
      }
  }
  
  func fetchConversionFromOneToAnother(from fromCurrency: String, to toCurrency: String)  -> Observable<Currency.ConversionFromOneToAnother> {
    let request = URLRequest(url: Self.baseURL.appendingPathComponent("currencies/\(fromCurrency)/\(toCurrency).json"))
    return URLSession.shared.rx.data(request: request)
      .map { [toCurrency] data in
        let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
        return convertedDataArray[toCurrency] as! Currency.ConversionFromOneToAnother
      }
  }
}

enum CurrencyNetworkError: Error, LocalizedError {
  case currenciesNotFound
  case currnecyConversionFailure
}
