// Copyright (c) 2019 Vincent Sit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

final class TestDataFetcher {
  typealias JSON = [String: [String: [Int]]]

  static let shared = TestDataFetcher()

  // Because the test data is loaded from the network,
  // the first test may be a little slower.
  lazy var data: JSON = {
    guard let url = URL(string: "https://raw.githubusercontent.com/VincentSit/ChinaMobilePhoneNumberRegex/test/test_data.json") else {
      fatalError("Failed to create URL.")
    }

    do {
      let data = try Data(contentsOf: url)
      guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
        fatalError("Failed to create JSON object.")
      }

      precondition(dictionary.count > 0, "The json file should not be empty.")
      return dictionary
    } catch {
      fatalError("Failed to load test data. \(error)")
    }
  }()

  lazy var reservedNumbers: [String] = {
    reservedIoTNumbers + reservedCarrierNumbers
  }()

  lazy var reservedIoTNumbers: [String] = {
    data["reserved"]!["iot"]!.map { String($0) }
  }()

  lazy var reservedCarrierNumbers: [String] = {
    data["reserved"]!["carrier"]!.map { String($0) }
  }()
}

// MARK: - VSRegexTestable

protocol VSRegexTestable {
  var testNumbers: [Int] { get }
  var testStringNumbers: [String] { get }
}

extension VSRegexTestable {
  var testStringNumbers: [String] {
    return testNumbers.map { String($0) }
  }
}

extension VSRegexPattern: VSRegexTestable {
  var testNumbers: [Int] {
    switch self {
    case .all:
      return VSRegexPattern.carrier(.all).testNumbers
        + VSRegexPattern.mvno(.all).testNumbers
        + VSRegexPattern.iot(.all).testNumbers
        + VSRegexPattern.dataOnly(.all).testNumbers
    case .sms:
      return VSRegexPattern.carrier(.all).testNumbers
        + VSRegexPattern.mvno(.all).testNumbers
        + VSRegexPattern.dataOnly(.all).testNumbers
    case let .carrier(`case`):
      return `case`.testNumbers
    case let .mvno(`case`):
      return `case`.testNumbers
    case let .iot(`case`):
      return `case`.testNumbers
    case let .dataOnly(`case`):
      return `case`.testNumbers
    }
  }
}

extension VSRegexPattern.Carrier: VSRegexTestable {
  var testNumbers: [Int] {
    switch self {
    case .all:
      return TestDataFetcher.shared.data["carrier"]!.values.reduce([], +)
    case .chinaMobile:
      return TestDataFetcher.shared.data["carrier"]!["china_mobile"]!
    case .chinaUnicom:
      return TestDataFetcher.shared.data["carrier"]!["china_unicom"]!
    case .chinaTelecom:
      return TestDataFetcher.shared.data["carrier"]!["china_telecom"]!
    case .inmarsat:
      return TestDataFetcher.shared.data["carrier"]!["inmarsat"]!
    case .miit:
      return TestDataFetcher.shared.data["carrier"]!["miit"]!
    }
  }
}

extension VSRegexPattern.MVNO: VSRegexTestable {
  var testNumbers: [Int] {
    switch self {
    case .all:
      return TestDataFetcher.shared.data["mvno"]!.values.reduce([], +)
    case .chinaMobile:
      return TestDataFetcher.shared.data["mvno"]!["china_mobile"]!
    case .chinaUnicom:
      return TestDataFetcher.shared.data["mvno"]!["china_unicom"]!
    case .chinaTelecom:
      return TestDataFetcher.shared.data["mvno"]!["china_telecom"]!
    }
  }
}

extension VSRegexPattern.IoT: VSRegexTestable {
  var testNumbers: [Int] {
    switch self {
    case .all:
      return TestDataFetcher.shared.data["iot"]!.values.reduce([], +)
    case .chinaMobile:
      return TestDataFetcher.shared.data["iot"]!["china_mobile"]!
    case .chinaUnicom:
      return TestDataFetcher.shared.data["iot"]!["china_unicom"]!
    case .chinaTelecom:
      return TestDataFetcher.shared.data["iot"]!["china_telecom"]!
    }
  }
}

extension VSRegexPattern.DataOnly: VSRegexTestable {
  var testNumbers: [Int] {
    switch self {
    case .all:
      return TestDataFetcher.shared.data["data_plan_only"]!.values.reduce([], +)
    case .chinaMobile:
      return TestDataFetcher.shared.data["data_plan_only"]!["china_mobile"]!
    case .chinaUnicom:
      return TestDataFetcher.shared.data["data_plan_only"]!["china_unicom"]!
    case .chinaTelecom:
      return TestDataFetcher.shared.data["data_plan_only"]!["china_telecom"]!
    }
  }
}

extension OptionSet where RawValue: FixedWidthInteger {
  func elements() -> AnySequence<Self> {
    var remainingBits = rawValue
    var bitMask: RawValue = 1
    return AnySequence {
      AnyIterator {
        while remainingBits != 0 {
          defer { bitMask = bitMask &* 2 }
          if remainingBits & bitMask != 0 {
            remainingBits = remainingBits & ~bitMask
            return Self(rawValue: bitMask)
          }
        }
        return nil
      }
    }
  }
}
