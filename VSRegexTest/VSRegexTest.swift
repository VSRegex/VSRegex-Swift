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

import XCTest

class VSRegexTest: XCTestCase {
  
  lazy var regularExpressionOptionsBitComponents: [UInt] = {
    let regularExpressionOptions: NSRegularExpression.Options = [
      .caseInsensitive,
      .allowCommentsAndWhitespace,
//      .ignoreMetacharacters,
      .dotMatchesLineSeparators,
      .anchorsMatchLines,
      .useUnixLineSeparators,
      .useUnicodeWordBoundaries
    ]
    return regularExpressionOptions.rawValue.bitComponents()
  }()
  
  lazy var matchingOptionsBitComponents: [UInt] = {
    let matchingOptions: NSRegularExpression.MatchingOptions = [
      .reportProgress,
      .reportCompletion,
      .anchored,
      .withTransparentBounds,
      .withoutAnchoringBounds
    ]
    return matchingOptions.rawValue.bitComponents()
  }()

  func testCreate() {
    for `case` in VSRegexPattern.allCases {
      XCTAssertNotNil(VSRegex(`case`))

      for index in regularExpressionOptionsBitComponents.enumerated() {
        let options = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(index.offset)))
        )
        XCTAssertNotNil(VSRegex(`case`, options: options))
      }
    }
  }

  func testCreateThrows() {
    for `case` in VSRegexPattern.allCases {
      XCTAssertNotNil(try VSRegex(pattern: `case`))
      
      for index in regularExpressionOptionsBitComponents.enumerated() {
        let options = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(index.offset)))
        )
        XCTAssertNotNil(try VSRegex(pattern: `case`, options: options))
      }
    }
  }

  func testFirstMatch() {
    for `case` in VSRegexPattern.allCases {
      let testNumbers = `case`.testStringNumbers
      
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )
        
        let regex = VSRegex(`case`, options: regularExpressionOptions)
        XCTAssertNotNil(regex)
        
        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          for number in testNumbers {
            XCTAssertNotNil(regex.firstMatch(number, options: matchingOptions))
            XCTAssertNotNil(regex.firstMatch(number, options: matchingOptions, range: NSRange(location: 0, length: number.count)))
            XCTAssertNil(regex.firstMatch(number, options: matchingOptions, range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testFirstMatchWithReservedNumbers() {
    for `case` in VSRegexPattern.allCases {
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )
        
        let regex = VSRegex(`case`, options: regularExpressionOptions)
        XCTAssertNotNil(regex)
        
        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          for number in TestDataFetcher.shared.reservedNumbers {
            XCTAssertNil(regex.firstMatch(number, options: matchingOptions))
            XCTAssertNil(regex.firstMatch(number, options: matchingOptions, range: NSRange(location: 0, length: number.count)))
            XCTAssertNil(regex.firstMatch(number, options: matchingOptions, range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testAllMatches() {
    for `case` in VSRegexPattern.allCases {
      let testNumbers = `case`.testStringNumbers
      
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )
        
        let regex = VSRegex(`case`, options: regularExpressionOptions)
        XCTAssertNotNil(regex)
        
        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          var matches = regex.allMatches(testNumbers, options: matchingOptions)
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.count > 0)

          matches = regex.allMatches(testNumbers, options: matchingOptions, range: NSRange(location: 0, length: `case`.minimumLength))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.count > 0)
          
          /// The reason is that when the range parameter is specified,
          /// the minimum required length for matching all numbers case is 11,
          /// while the IoT number length is 13,
          /// so the matching result does not include the IoT number.
          if case .all = `case` {
            XCTAssertTrue(matches.count != testNumbers.count)
          } else {
            XCTAssertTrue(matches.count == testNumbers.count)
          }
          
          matches = regex.allMatches(testNumbers, range: NSRange(location: 0, length: 1))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          
          matches = regex.allMatches(testNumbers, options: matchingOptions, range: NSRange(location: 0, length: 1))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
        }
      }
    }
  }

  func testAllMatchesWithReservedNumbers() {
    for `case` in VSRegexPattern.allCases {
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )
        
        let regex = VSRegex(`case`, options: regularExpressionOptions)
        XCTAssertNotNil(regex)
        
        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          let numbers = TestDataFetcher.shared.reservedNumbers
          var matches = regex.allMatches(numbers, options: matchingOptions)
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)

          matches = regex.allMatches(numbers, options: matchingOptions, range: NSRange(location: 0, length: `case`.minimumLength))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          
          matches = regex.allMatches(numbers, range: NSRange(location: 0, length: 1))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          
          matches = regex.allMatches(numbers, options: matchingOptions, range: NSRange(location: 0, length: 1))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
        }
      }
    }
  }

  func testMatches() {
    for `case` in VSRegexPattern.allCases {
      let testNumbers = `case`.testStringNumbers
      
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )
        
        let regex = VSRegex(`case`, options: regularExpressionOptions)
        XCTAssertNotNil(regex)
        
        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          for number in testNumbers {
            XCTAssertTrue(regex.matches(number, options: matchingOptions))
            XCTAssertTrue(regex.matches(number, options: matchingOptions, range: NSRange(location: 0, length: number.count)))
            XCTAssertFalse(regex.matches(number, options: matchingOptions, range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testMatchesWithReservedNumbers() {
    for `case` in VSRegexPattern.allCases {
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )
        
        let regex = VSRegex(`case`, options: regularExpressionOptions)
        XCTAssertNotNil(regex)
        
        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          for number in TestDataFetcher.shared.reservedNumbers {
            XCTAssertFalse(regex.matches(number, options: matchingOptions))
            XCTAssertFalse(regex.matches(number, options: matchingOptions, range: NSRange(location: 0, length: number.count)))
            XCTAssertFalse(regex.matches(number, options: matchingOptions, range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testStaticWrappers() {
    for `case` in VSRegexPattern.allCases {
      let testNumbers = `case`.testStringNumbers
      
      for reOptionIndex in regularExpressionOptionsBitComponents.enumerated() {
        let regularExpressionOptions = NSRegularExpression.Options(
          rawValue: UInt(bitComponents: Array(regularExpressionOptionsBitComponents.prefix(reOptionIndex.offset)))
        )

        for matchingOptionIndex in matchingOptionsBitComponents.enumerated() {
          let matchingOptions = NSRegularExpression.MatchingOptions(
            rawValue: UInt(bitComponents: Array(matchingOptionsBitComponents.prefix(matchingOptionIndex.offset)))
          )
          
          for number in testNumbers {
            XCTAssertTrue(
              VSRegex.matches(number,
                              in: `case`,
                              regularExpressionOptions: regularExpressionOptions,
                              matchingOptions: matchingOptions)
            )
            XCTAssertTrue(
              VSRegex.is(number,
                         matches: `case`,
                         regularExpressionOptions: regularExpressionOptions,
                         matchingOptions: matchingOptions)
            )
          }
        }
      }
    }
  }
}
