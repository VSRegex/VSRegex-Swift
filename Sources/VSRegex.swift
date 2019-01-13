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

/// Used to load the VSRegex.bundle in CocoaPods.
private final class PrivateBundleClass {}

internal protocol VSRegexMatchable {
  typealias JSON = [String: [String: String]]

  /// A dictionary object that stores all regular expression patterns.
  var regexDict: JSON { get }

  /// Regular expression pattern.
  var pattern: String { get }

  /// The minimum length of the string to match.
  var minimumLength: Int { get }
}

internal extension VSRegexMatchable {
  var regexDict: JSON {
    #if VSREGEX_TEST
      let bundle = Bundle(for: VSRegexTest.self)
    #else
      guard let bundleURL = Bundle(for: PrivateBundleClass.self).resourceURL?.appendingPathComponent("VSRegex.bundle"),
        let bundle = Bundle(url: bundleURL) else {
        fatalError("VSRegex: Failed to load the VSRegex.bundle.")
      }
    #endif

    guard let fileURL = bundle.url(forResource: "regex", withExtension: "json") else {
      fatalError("VSRegex: Failed to find the path of regex.json.")
    }

    do {
      let data = try Data(contentsOf: fileURL)
      guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
        fatalError("VSRegex: Failed to create JSON object.")
      }
      precondition(dictionary.count > 0, "VSRegex: The json file should not be empty.")
      return dictionary
    } catch {
      fatalError("VSRegex: Failed to read regex.json. \(error)")
    }
  }
}

/// Regular expression patterns for used to match mobile numbers in mainland China.
///
/// - all: Match all numbers. (Phone number + IoT number + Data only number)
/// - sms: Match all numbers with SMS. (Phone number + Data only number)
/// - carrier: Match carrier number based on specified option.
/// - mvno: Match MVNO number based on specified option.
/// - iot: Match IoT number based on specified option.
/// - dataOnly: Match data only number based on specified option.
public enum VSRegexPattern: VSRegexMatchable {
  case all
  case sms
  case carrier(Carrier)
  case mvno(MVNO)
  case iot(IoT)
  case dataOnly(DataOnly)

  // MARK: VSRegexMatchable

  var pattern: String {
    switch self {
    case .all:
      return regexDict["misc"]!["all"]!
    case .sms:
      return regexDict["misc"]!["sms"]!
    case let .carrier(`case`):
      return `case`.pattern
    case let .mvno(`case`):
      return `case`.pattern
    case let .iot(`case`):
      return `case`.pattern
    case let .dataOnly(`case`):
      return `case`.pattern
    }
  }

  var minimumLength: Int {
    switch self {
    case .all:
      return Int(regexDict["misc"]!["all_min_length"]!)!
    case .sms:
      return Int(regexDict["misc"]!["sms_min_length"]!)!
    case let .carrier(`case`):
      return `case`.minimumLength
    case let .mvno(`case`):
      return `case`.minimumLength
    case let .iot(`case`):
      return `case`.minimumLength
    case let .dataOnly(`case`):
      return `case`.minimumLength
    }
  }
}

public extension VSRegexPattern {
  /// Patterns for used to match the mobile number of the carrier.
  ///
  /// - all: Match all the carrier mobile numbers.
  /// - chinaMobile: Match the China Mobile mobile numbers.
  /// - chinaUnicom: Match the China Unicom mobile numbers.
  /// - chinaTelecom: Match the China Telecom mobile numbers.
  /// - inmarsat: Match the inmarsat mobile numbers.
  /// - miit: Match the miit mobile numbers.
  public enum Carrier: VSRegexMatchable {
    case all
    case chinaMobile
    case chinaUnicom
    case chinaTelecom
    case inmarsat
    case miit

    // MARK: VSRegexMatchable

    var pattern: String {
      switch self {
      case .all:
        return regexDict["carrier"]!["all"]!
      case .chinaMobile:
        return regexDict["carrier"]!["china_mobile"]!
      case .chinaUnicom:
        return regexDict["carrier"]!["china_unicom"]!
      case .chinaTelecom:
        return regexDict["carrier"]!["china_telecom"]!
      case .inmarsat:
        return regexDict["carrier"]!["inmarsat"]!
      case .miit:
        return regexDict["carrier"]!["miit"]!
      }
    }

    var minimumLength: Int {
      return Int(regexDict["carrier"]!["min_length"]!)!
    }
  }

  /// Patterns for used to match the mobile number operated by the mobile virtual network operator.
  ///
  /// - all: Match all the MVNO mobile numbers.
  /// - chinaMobile: Match the mobile number of China Mobile operated by the MVNO.
  /// - chinaUnicom: Match the mobile number of China Unicom operated by the MVNO.
  /// - chinaTelecom: Match the mobile number of China Telecom operated by the MVNO.
  public enum MVNO: VSRegexMatchable {
    case all
    case chinaMobile
    case chinaUnicom
    case chinaTelecom

    // MARK: VSRegexMatchable

    var pattern: String {
      switch self {
      case .all:
        return regexDict["mvno"]!["all"]!
      case .chinaMobile:
        return regexDict["mvno"]!["china_mobile"]!
      case .chinaUnicom:
        return regexDict["mvno"]!["china_unicom"]!
      case .chinaTelecom:
        return regexDict["mvno"]!["china_telecom"]!
      }
    }

    var minimumLength: Int {
      return Int(regexDict["mvno"]!["min_length"]!)!
    }
  }

  /// Patterns for used to match the IoT numbers.
  ///
  /// - all: Match all the IoT numbers.
  /// - chinaMobile: Match the IoT numbers belonging to China Mobile.
  /// - chinaUnicom: Match the IoT numbers belonging to China Unicom.
  /// - chinaTelecom: Match the IoT numbers belonging to China Telecom.
  public enum IoT: VSRegexMatchable {
    case all
    case chinaMobile
    case chinaUnicom
    case chinaTelecom

    // MARK: VSRegexMatchable

    var pattern: String {
      switch self {
      case .all:
        return regexDict["iot"]!["all"]!
      case .chinaMobile:
        return regexDict["iot"]!["china_mobile"]!
      case .chinaUnicom:
        return regexDict["iot"]!["china_unicom"]!
      case .chinaTelecom:
        return regexDict["iot"]!["china_telecom"]!
      }
    }

    var minimumLength: Int {
      return Int(regexDict["iot"]!["min_length"]!)!
    }
  }

  /// Patterns for used to match the data-plans only numbers.
  ///
  /// - all: Match all the data-plans only numbers.
  /// - chinaMobile: Match the data-plans only numbers belonging to China Mobile.
  /// - chinaUnicom: Match the data-plans only numbers belonging to China Unicom.
  /// - chinaTelecom: Match the data-plans only numbers belonging to China Telecom.
  public enum DataOnly: VSRegexMatchable {
    case all
    case chinaMobile
    case chinaUnicom
    case chinaTelecom

    // MARK: VSRegexMatchable

    var pattern: String {
      switch self {
      case .all:
        return regexDict["data_plan_only"]!["all"]!
      case .chinaMobile:
        return regexDict["data_plan_only"]!["china_mobile"]!
      case .chinaUnicom:
        return regexDict["data_plan_only"]!["china_unicom"]!
      case .chinaTelecom:
        return regexDict["data_plan_only"]!["china_telecom"]!
      }
    }

    var minimumLength: Int {
      return Int(regexDict["data_plan_only"]!["min_length"]!)!
    }
  }
}

// MARK: - CaseIterable

#if swift(>=4.2)

  extension VSRegexPattern: CaseIterable {
    public static var allCases: [VSRegexPattern] {
      return [.all, .sms]
        + Carrier.allCases.map(VSRegexPattern.carrier)
        + MVNO.allCases.map(VSRegexPattern.mvno)
        + IoT.allCases.map(VSRegexPattern.iot)
        + DataOnly.allCases.map(VSRegexPattern.dataOnly)
    }
  }

  extension VSRegexPattern.Carrier: CaseIterable {}
  extension VSRegexPattern.MVNO: CaseIterable {}
  extension VSRegexPattern.IoT: CaseIterable {}
  extension VSRegexPattern.DataOnly: CaseIterable {}

#endif

// MARK: - VSRegex

/// A structure used to match mobile numbers in mainland China.
public struct VSRegex {
  /// The regular expression matching pattern for this object.
  public let matchingPattern: VSRegexPattern

  /// The NSRegularExpression object that really does the matching work.
  public let regularExpression: NSRegularExpression

  /// Create a `VSRegex` based on pattern and regular expression options.
  ///
  /// - Parameters:
  ///   - pattern: The regular expression pattern to compile.
  ///   - options: The regular expression options that are applied to the expression during matching.
  /// - Throws: A value of `ErrorType` describing the invalid regular expression.
  public init(pattern: VSRegexPattern, options: NSRegularExpression.Options = []) throws {
    matchingPattern = pattern
    regularExpression = try NSRegularExpression(pattern: pattern.pattern, options: options)
  }

  /// Create a `VSRegex` based on pattern and regular expression options.
  ///
  /// Unlike `VSRegex.init(pattern:options:)` this initialiser is not failable. If `pattern`
  /// is an invalid regular expression, it is considered programmer error rather
  /// than a recoverable runtime error, so this initialiser instead raises a
  /// precondition failure.
  ///
  /// - requires: `pattern` is a valid regular expression.
  ///
  /// - Parameters:
  ///   - pattern: The regular expression pattern to compile.
  ///   - options: The regular expression options that are applied to the expression during matching.
  public init(_ pattern: VSRegexPattern = .all, options: NSRegularExpression.Options = []) {
    matchingPattern = pattern
    do {
      regularExpression = try NSRegularExpression(pattern: pattern.pattern, options: options)
    } catch {
      preconditionFailure("VSRegex: Unexpected error creating regex: \(error)")
    }
  }

  /// Search for the first string that matches the `matchingPattern`.
  ///
  /// - Parameters:
  ///   - string: The string to match against.
  ///   - options: The regular expression matching options that are applied to the expression during matching.
  ///   - range: The range of the string to search.
  /// - Returns: An optional `String` object describing the first match, or `nil`.
  public func firstMatch(_ string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> String? {
    guard string.count >= matchingPattern.minimumLength else { return nil }

    let range = range ?? NSRange(location: 0, length: string.count)
    guard range.length - range.location >= matchingPattern.minimumLength else { return nil }

    guard let result = regularExpression.firstMatch(in: string, options: options, range: range) else { return nil }
    return Range(result.range, in: string).map { String(string[$0]) }
  }

  /// Search for all strings that match the `matchingPattern`.
  ///
  /// - Parameters:
  ///   - strings: The string array to match against.
  ///   - options: The regular expression matching options that are applied to the expression during matching.
  ///   - range: The range of the string to search.
  /// - Returns: An array of `String` describing every match, or an empty array.
  public func allMatches(_ strings: [String], options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> [String] {
    guard strings.count > 0 else { return [] }

    return strings.reduce([]) { (results, string) -> [String] in
      guard string.count >= matchingPattern.minimumLength else { return [] }

      let range = range ?? NSRange(string.startIndex..., in: string)
      guard range.length - range.location >= matchingPattern.minimumLength else { return [] }

      let matches = regularExpression.matches(in: string, options: options, range: range)
      return results + matches.compactMap { Range($0.range, in: string).map { String(string[$0]) } }
    }
  }

  /// Tests if the string matches the `matchingPattern` with the specified parameters.
  ///
  /// - Parameters:
  ///   - string: The string to match against.
  ///   - options: The regular expression matching options that are applied to the expression during matching.
  ///   - range: The range of the string to search.
  /// - Returns: `true` if the regular expression matches, otherwise `false`.
  public func matches(_ string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> Bool {
    return firstMatch(string, options: options, range: range) != nil
  }

  /// Tests if the string matches the `matchingPattern` with the specified parameters.
  ///
  /// - Parameters:
  ///   - string: The string to match against.
  ///   - pattern: The regular expression pattern to compile.
  ///   - regularExpressionOptions: The regular expression options that are applied to the expression during matching.
  ///   - matchingOptions: The regular expression matching options that are applied to the expression during matching.
  ///   - range: The range of the string to search.
  /// - Returns: `true` if the regular expression matches, otherwise `false`.
  public static func matches(_ string: String,
                             in pattern: VSRegexPattern = .all,
                             regularExpressionOptions: NSRegularExpression.Options = [],
                             matchingOptions: NSRegularExpression.MatchingOptions = [],
                             range: NSRange? = nil) -> Bool {
    return VSRegex(pattern, options: regularExpressionOptions).matches(string, options: matchingOptions, range: range)
  }

  /// Syntax Sugar for matches(_:in:regularExpressionOptions:matchingOptions:range:).
  ///
  /// - Parameters:
  ///   - string: The string to match against.
  ///   - matches: The regular expression pattern to compile.
  ///   - regularExpressionOptions: The regular expression options that are applied to the expression during matching.
  ///   - matchingOptions: The regular expression matching options that are applied to the expression during matching.
  ///   - range: The range of the string to search.
  /// - Returns: `true` if the regular expression matches, otherwise `false`.
  public static func `is`(_ string: String,
                          matches pattern: VSRegexPattern,
                          regularExpressionOptions: NSRegularExpression.Options = [],
                          matchingOptions: NSRegularExpression.MatchingOptions = [],
                          range: NSRange? = nil) -> Bool {
    return matches(string, in: pattern,
                   regularExpressionOptions: regularExpressionOptions,
                   matchingOptions: matchingOptions, range: range)
  }
}

// MARK: - Equatable

extension VSRegex: Equatable {
  public static func == (lhs: VSRegex, rhs: VSRegex) -> Bool {
    return lhs.matchingPattern.pattern == rhs.matchingPattern.pattern
      && lhs.regularExpression == rhs.regularExpression
  }
}

// MARK: - Hashable

extension VSRegex: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(matchingPattern.pattern)
    hasher.combine(regularExpression)
  }
}
