//
//  FreeCurrencyRatesTests.swift
//  FreeCurrencyRatesTests
//
//  Created by Hiroki Minami on 2023-02-17.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import OHHTTPStubs

@testable import FreeCurrencyRates

final class FreeCurrencyRatesTests: XCTestCase {
  let obj = ["array": ["foo", "bar"], "foo": "bar"] as [String: AnyHashable]
  let request = URL(string: "http://freeCurrencyRates.com")!
  let requestNotFound = URL(string: "http://freeCurrencyRatesNotFound.com")!
  let errorRequest = URL(string: "http://freeCurrencyRatesError.com")!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    stub(condition: isHost("freeCurrencyRates.com")) { request in
      return HTTPStubsResponse(jsonObject: self.obj, statusCode: 200, headers: nil)
    }
    
    stub(condition: isHost("freeCurrencyRatesNotFound.com")) { _ in
      return HTTPStubsResponse(jsonObject: self.obj, statusCode: 404, headers: nil)
    }
    
    stub(condition: isHost("freeCurrencyRatesError.com")) { _ in
      return HTTPStubsResponse(error: CurrencyNetworkController.CurrencyNetworkError.serverFailure)
    }
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    HTTPStubs.removeAllStubs()
  }
  
  /// test buildRequest
  /// successful request
  func testBuildRequest() throws {
    let observable = CurrencyNetworkController.shared.buildRequest(url: request)
    let obj = self.obj
    
    do {
      let result = try observable.toBlocking().first()!
      let data = try! JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyHashable]
      expect (data) == obj
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  /// test buildRequest
  /// error request
  /// 404 http response
  func testBuildRequestNotFound() throws {
    var erroredCorrectly = false
    let observable = CurrencyNetworkController.shared.buildRequest(url: requestNotFound)
    
    do {
      _ = try observable.toBlocking().first()
      assertionFailure("Error is expected")
    } catch CurrencyNetworkController.CurrencyNetworkError.currenciesNotFound {
      erroredCorrectly = true
    } catch {
      assertionFailure("Another error is expected")
    }
    expect(erroredCorrectly) == true
  }
  
  /// test buildRequest
  /// error request
  /// 500 http response
  func testBuildRequestServerError() throws {
    var erroredCorrectly = false
    let observable = CurrencyNetworkController.shared.buildRequest(url: errorRequest)
    
    do {
      let result = try observable.toBlocking().first()
      assertionFailure("Error is expected")
    } catch CurrencyNetworkController.CurrencyNetworkError.serverFailure, CurrencyNetworkController.CurrencyNetworkError.currenciesNotFound {
      assertionFailure("Another error is expected")
    } catch {
      erroredCorrectly = true
    }
    expect(erroredCorrectly) == true
  }
  
  /// test fetch conversion from base currency
  /// successful request
  func testFetchConversionFromBaseCurrency() throws {
    let observable = CurrencyNetworkController.shared.fetchConversionFromBaseCurrency(currency: "usd")
    
    do {
      let result = try !observable.toBlocking().first()!.isEmpty
      XCTAssertEqual(true, result)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  /// test fetch conversion from base currency
  /// not found
  func testFetchConversionFromBaseCurrencyNotFound() throws {
    var erroredCorrectly = false
    let observable = CurrencyNetworkController.shared.fetchConversionFromBaseCurrency(currency: "test")
    
    do {
      _ = try observable.toBlocking().first()
      assertionFailure("Error is expected")
    } catch CurrencyNetworkController.CurrencyNetworkError.currenciesNotFound {
      erroredCorrectly = true
    } catch {
      assertionFailure("Another error is expected")
    }
    expect(erroredCorrectly) == true
  }
  
  /// test fetch conversion from one to another
  ///  successful request
  func testfetchConversionFromOneToAnother() throws {
    var erroredCorrectly = false
    let observable = CurrencyNetworkController.shared.fetchConversionFromOneToAnother(from: "usd", to: "cad")
    
    do {
      let _ = try observable.toBlocking().first()
      erroredCorrectly = true
    } catch {
      XCTFail(error.localizedDescription)
    }
    expect(erroredCorrectly) == true
  }
  
  /// test fetch conversion from one to another
  ///  not found
  func testfetchConversionFromOneToAnotherNotFound() throws {
    var erroredCorrectly = false
    let observable = CurrencyNetworkController.shared.fetchConversionFromOneToAnother(from: "usd", to: "test")
    
    do {
      _ = try observable.toBlocking().first()
      assertionFailure("Error is expected")
    } catch CurrencyNetworkController.CurrencyNetworkError.currenciesNotFound {
      erroredCorrectly = true
    } catch {
      assertionFailure("Another error is expected")
    }
    expect(erroredCorrectly) == true
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
