//
//  CurrencyNetworkController.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import Foundation

struct CurrencyNetworkController {
  static let baseURL = URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/")!
  static let shared = CurrencyNetworkController()
  
  private init() {}
  
  func fetchListOfCurrnecy() async throws -> [String: String] {
    let listURL = Self.baseURL.appendingPathComponent("currencies.json")
    let (data, response) = try await URLSession.shared.data(from: listURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw CurrencyNetworkError.currenciesNotFound }
    
    let decoder = JSONDecoder()
    let listResponse = try decoder.decode([String: String].self, from: data)
    
    return listResponse
  }
  
  func fetchConversionFromBaseCurrency(currency: String) async throws -> [String: Double] {
    let baseCurrencyURL = Self.baseURL.appendingPathComponent("currencies/\(currency).json")
    let (data, response) = try await URLSession.shared.data(from: baseCurrencyURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw CurrencyNetworkError.currenciesNotFound }
    
    let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
    if let conversion = convertedDataArray[currency] as? [String: Double] {
      return conversion
    } else {
      throw CurrencyNetworkError.currenciesNotFound
    }
  }
  
  func fetchConversionFromOneToAnother(from fromCurrency: String, to toCurrency: String) async throws -> Double {
    let conversionURL = Self.baseURL.appendingPathComponent("currencies/\(fromCurrency)/\(toCurrency).json")
    let (data, response) = try await URLSession.shared.data(from: conversionURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw CurrencyNetworkError.currenciesNotFound }
    
    let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
    if let conversion = convertedDataArray[toCurrency] as? Double {
      return conversion
    } else {
      throw CurrencyNetworkError.currenciesNotFound
    }
  }
}

enum CurrencyNetworkError: Error, LocalizedError {
  case currenciesNotFound
//  case menuItemsNotFound
//  case orderRequestFailed
//  case imageDataMissing
}
