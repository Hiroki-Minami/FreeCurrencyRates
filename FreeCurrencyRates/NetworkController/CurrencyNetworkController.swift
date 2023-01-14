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
  
  func fetchConversionFromBaseCurrency(currency: String) async throws -> [String: String] {
    let baseCurrencyURL = Self.baseURL.appendingPathComponent("currencies/\(currency).json")
    let (data, response) = try await URLSession.shared.data(from: baseCurrencyURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw CurrencyNetworkError.currenciesNotFound }
    
    let convertedDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
    
//    print(convertedDataArray[currency])
//    print(type(of: convertedDataArray[currency]))
//
//    if let conversion = convertedDataArray[currency] {
//      let str = String(data: , encoding: <#T##String.Encoding#>
//
//      return [:]
//    } else {
//      throw CurrencyNetworkError.currenciesNotFound
//    }
//    print(convertedDataArray[currency])
//    let convertedData = convertedDataArray.map { jsonData -> [String: Any] in
//      return jsonData as! [String: Any]
//    }
//
//    print(convertedData)
//
////    let conversion = convertedData[currency] as! [String: Double]
//    let decoder = JSONDecoder()
    
    // TODO:
//    data.
//    let baseCurrencyResponse = try decoder.decode([String: Any].self, from: data)
    
//    return Array(listResponse.keys)
    return [:]
  }
  
  func fetchConversionFromOneToAnother(from fromCurrency: String, to toCurrency: String) async throws -> Double {
    let conversionURL = Self.baseURL.appendingPathComponent("currencies/\(fromCurrency)/\(toCurrency).json")
    let (data, response) = try await URLSession.shared.data(from: conversionURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw CurrencyNetworkError.currenciesNotFound }
    
    let decoder = JSONDecoder()
    let conversionResponse = try decoder.decode([String: String].self, from: data)
    
//    return Array(listResponse.keys)
    return 0.0
  }
}

enum CurrencyNetworkError: Error, LocalizedError {
  case currenciesNotFound
//  case menuItemsNotFound
//  case orderRequestFailed
//  case imageDataMissing
}
