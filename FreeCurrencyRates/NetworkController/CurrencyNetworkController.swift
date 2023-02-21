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
    return buildRequest(url: Self.baseURL.appendingPathComponent("currencies.json"))
      .map { data in
        try JSONDecoder().decode(Currency.CurrencyType.self, from: data)
      }
  }
  
  func fetchConversionFromBaseCurrency(currency: String) -> Observable<Currency.ConversionFromBaseCurrency> {
    return buildRequest(url: Self.baseURL.appendingPathComponent("currencies/\(currency).json"))
      .map { data in
        let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
        return convertedDataArray[currency] as! Currency.ConversionFromBaseCurrency
      }
  }
  
  func fetchConversionFromOneToAnother(from fromCurrency: String, to toCurrency: String)  -> Observable<Currency.ConversionFromOneToAnother> {
    return buildRequest(url: Self.baseURL.appendingPathComponent("currencies/\(fromCurrency)/\(toCurrency).json"))
      .map { [toCurrency] data in
        let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
        return convertedDataArray[toCurrency] as! Currency.ConversionFromOneToAnother
      }
  }
  
  func buildRequest(url: URL) -> Observable<Data> {
    let request = URLRequest(url: url)
    
    return URLSession.shared.rx.response(request: request)
      .map { response, data in
        switch response.statusCode {
        case 200 ..< 300:
          return data
        case 400 ..< 500:
          throw CurrencyNetworkError.currenciesNotFound
        default:
          throw CurrencyNetworkError.serverFailure
        }
      }
  }
}

extension CurrencyNetworkController {
  enum CurrencyNetworkError: Error, LocalizedError {
    case currenciesNotFound
    case serverFailure
  }
}

