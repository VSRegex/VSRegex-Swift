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
  lazy var regularExpressionOptions: NSRegularExpression.Options = {
    [
      .caseInsensitive,
      .allowCommentsAndWhitespace,
      .ignoreMetacharacters,
      .dotMatchesLineSeparators,
      .anchorsMatchLines,
      .useUnixLineSeparators,
      .useUnicodeWordBoundaries
    ]
  }()

  lazy var matchingOptions: NSRegularExpression.MatchingOptions = {
    [
      .reportProgress,
      .reportCompletion,
      .anchored,
      .withTransparentBounds,
      .withoutAnchoringBounds
    ]
  }()

  func testCreate() {
    for `case` in VSRegexPattern.allCases {
      XCTAssertNotNil(VSRegex(`case`))

      for option1 in regularExpressionOptions.elements() {
        XCTAssertNotNil(VSRegex(`case`, options: [option1]))

        for option2 in regularExpressionOptions.elements() {
          XCTAssertNotNil(VSRegex(`case`, options: [option2]))
          XCTAssertNotNil(VSRegex(`case`, options: [option1, option2]))
        }
      }
    }
  }

  func testCreateThrows() {
    do {
      for `case` in VSRegexPattern.allCases {
        XCTAssertNotNil(try VSRegex(pattern: `case`))

        for option1 in regularExpressionOptions.elements() {
          XCTAssertNotNil(try VSRegex(pattern: `case`, options: [option1]))

          for option2 in regularExpressionOptions.elements() {
            XCTAssertNotNil(try VSRegex(pattern: `case`, options: [option2]))
            XCTAssertNotNil(try VSRegex(pattern: `case`, options: [option1, option2]))
          }
        }
      }
    } catch {
      XCTAssertNotNil(nil, "\(error)")
    }
  }

  func testFirstMatch() {
    for `case` in VSRegexPattern.allCases {
      let regex = VSRegex(`case`)
      XCTAssertNotNil(regex)

      for number in `case`.testStringNumbers {
        XCTAssertNotNil(regex.firstMatch(number))
        XCTAssertNotNil(regex.firstMatch(number, range: NSRange(location: 0, length: number.count)))
        XCTAssertNil(regex.firstMatch(number, range: NSRange(location: 0, length: 1)))

        for option1 in matchingOptions.elements() {
          XCTAssertNotNil(regex.firstMatch(number, options: [option1]))
          XCTAssertNotNil(regex.firstMatch(number, options: [option1], range: NSRange(location: 0, length: number.count)))
          XCTAssertNil(regex.firstMatch(number, options: [option1], range: NSRange(location: 0, length: 1)))

          for option2 in matchingOptions.elements() {
            XCTAssertNotNil(regex.firstMatch(number, options: [option2]))
            XCTAssertNotNil(regex.firstMatch(number, options: [option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertNil(regex.firstMatch(number, options: [option2], range: NSRange(location: 0, length: 1)))

            XCTAssertNotNil(regex.firstMatch(number, options: [option1, option2]))
            XCTAssertNotNil(regex.firstMatch(number, options: [option1, option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertNil(regex.firstMatch(number, options: [option1, option2], range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testFirstMatchWithReservedNumbers() {
    for `case` in VSRegexPattern.allCases {
      let regex = VSRegex(`case`)
      XCTAssertNotNil(regex)

      for number in TestDataFetcher.shared.reservedNumbers {
        XCTAssertNil(regex.firstMatch(number))
        XCTAssertNil(regex.firstMatch(number, range: NSRange(location: 0, length: number.count)))
        XCTAssertNil(regex.firstMatch(number, range: NSRange(location: 0, length: 1)))

        for option1 in matchingOptions.elements() {
          XCTAssertNil(regex.firstMatch(number, options: [option1]))
          XCTAssertNil(regex.firstMatch(number, options: [option1], range: NSRange(location: 0, length: number.count)))
          XCTAssertNil(regex.firstMatch(number, options: [option1], range: NSRange(location: 0, length: 1)))

          for option2 in matchingOptions.elements() {
            XCTAssertNil(regex.firstMatch(number, options: [option2]))
            XCTAssertNil(regex.firstMatch(number, options: [option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertNil(regex.firstMatch(number, options: [option2], range: NSRange(location: 0, length: 1)))

            XCTAssertNil(regex.firstMatch(number, options: [option1, option2]))
            XCTAssertNil(regex.firstMatch(number, options: [option1, option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertNil(regex.firstMatch(number, options: [option1, option2], range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testAllMatches() {
    for `case` in VSRegexPattern.allCases {
      let regex = VSRegex(`case`)
      XCTAssertNotNil(regex)

      let numbers = `case`.testStringNumbers
      var matches = regex.allMatches(numbers)

      XCTAssertNotNil(matches)
      XCTAssertTrue(matches.count > 0 && matches.count == numbers.count)

      matches = regex.allMatches(numbers, range: NSRange(location: 0, length: `case`.minimumLength))
      XCTAssertNotNil(matches)
      XCTAssertTrue(matches.count > 0)

      /// The reason is that when the range parameter is specified,
      /// the minimum required length for matching all numbers case is 11,
      /// while the IoT number length is 13,
      /// so the matching result does not include the IoT number.
      if case .all = `case` {
        XCTAssertTrue(matches.count != numbers.count)
      } else {
        XCTAssertTrue(matches.count == numbers.count)
      }

      matches = regex.allMatches(numbers, range: NSRange(location: 0, length: 1))
      XCTAssertTrue(matches.isEmpty)

      for option1 in matchingOptions.elements() {
        matches = regex.allMatches(numbers, options: [option1])
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.count > 0 && matches.count == numbers.count)

        matches = regex.allMatches(numbers, options: [option1], range: NSRange(location: 0, length: `case`.minimumLength))
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.count > 0)

        if case .all = `case` {
          XCTAssertTrue(matches.count != numbers.count)
        } else {
          XCTAssertTrue(matches.count == numbers.count)
        }

        matches = regex.allMatches(numbers, options: [option1], range: NSRange(location: 0, length: 1))
        XCTAssertTrue(matches.isEmpty)

        for option2 in matchingOptions.elements() {
          matches = regex.allMatches(numbers, options: [option2])
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.count > 0 && matches.count == numbers.count)

          matches = regex.allMatches(numbers, options: [option2], range: NSRange(location: 0, length: `case`.minimumLength))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.count > 0)

          if case .all = `case` {
            XCTAssertTrue(matches.count != numbers.count)
          } else {
            XCTAssertTrue(matches.count == numbers.count)
          }

          matches = regex.allMatches(numbers, options: [option2], range: NSRange(location: 0, length: 1))
          XCTAssertTrue(matches.isEmpty)

          matches = regex.allMatches(numbers, options: [option1, option2])
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.count > 0 && matches.count == numbers.count)

          matches = regex.allMatches(numbers, options: [option1, option2], range: NSRange(location: 0, length: `case`.minimumLength))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.count > 0)

          if case .all = `case` {
            XCTAssertTrue(matches.count != numbers.count)
          } else {
            XCTAssertTrue(matches.count == numbers.count)
          }

          matches = regex.allMatches(numbers, options: [option1, option2], range: NSRange(location: 0, length: 1))
          XCTAssertTrue(matches.isEmpty)
        }
      }
    }
  }

  func testAllMatchesWithReservedNumbers() {
    for `case` in VSRegexPattern.allCases {
      let regex = VSRegex(`case`)
      XCTAssertNotNil(regex)

      let numbers = TestDataFetcher.shared.reservedNumbers
      var matches = regex.allMatches(numbers)

      XCTAssertNotNil(matches)
      XCTAssertTrue(matches.isEmpty)

      matches = regex.allMatches(numbers, range: NSRange(location: 0, length: `case`.minimumLength))
      XCTAssertNotNil(matches)
      XCTAssertTrue(matches.isEmpty)
      XCTAssertTrue(matches.count != numbers.count)

      matches = regex.allMatches(numbers, range: NSRange(location: 0, length: 1))
      XCTAssertTrue(matches.isEmpty)

      for option1 in matchingOptions.elements() {
        matches = regex.allMatches(numbers, options: [option1])
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.isEmpty)
        XCTAssertTrue(matches.count != numbers.count)

        matches = regex.allMatches(numbers, options: [option1], range: NSRange(location: 0, length: `case`.minimumLength))
        XCTAssertNotNil(matches)
        XCTAssertTrue(matches.isEmpty)
        XCTAssertTrue(matches.count != numbers.count)

        matches = regex.allMatches(numbers, options: [option1], range: NSRange(location: 0, length: 1))
        XCTAssertTrue(matches.isEmpty)
        XCTAssertTrue(matches.count != numbers.count)

        for option2 in matchingOptions.elements() {
          matches = regex.allMatches(numbers, options: [option2])
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          XCTAssertTrue(matches.count != numbers.count)

          matches = regex.allMatches(numbers, options: [option2], range: NSRange(location: 0, length: `case`.minimumLength))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          XCTAssertTrue(matches.count != numbers.count)

          matches = regex.allMatches(numbers, options: [option2], range: NSRange(location: 0, length: 1))
          XCTAssertTrue(matches.isEmpty)
          XCTAssertTrue(matches.count != numbers.count)

          matches = regex.allMatches(numbers, options: [option1, option2])
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          XCTAssertTrue(matches.count != numbers.count)

          matches = regex.allMatches(numbers, options: [option1, option2], range: NSRange(location: 0, length: `case`.minimumLength))
          XCTAssertNotNil(matches)
          XCTAssertTrue(matches.isEmpty)
          XCTAssertTrue(matches.count != numbers.count)

          matches = regex.allMatches(numbers, options: [option1, option2], range: NSRange(location: 0, length: 1))
          XCTAssertTrue(matches.isEmpty)
          XCTAssertTrue(matches.count != numbers.count)
        }
      }
    }
  }

  func testMatches() {
    for `case` in VSRegexPattern.allCases {
      let regex = VSRegex(`case`)
      XCTAssertNotNil(regex)

      for number in `case`.testStringNumbers {
        XCTAssertTrue(regex.matches(number))
        XCTAssertTrue(regex.matches(number, range: NSRange(location: 0, length: number.count)))
        XCTAssertFalse(regex.matches(number, range: NSRange(location: 0, length: 1)))

        for option1 in matchingOptions.elements() {
          XCTAssertTrue(regex.matches(number, options: [option1]))
          XCTAssertTrue(regex.matches(number, options: [option1], range: NSRange(location: 0, length: number.count)))
          XCTAssertFalse(regex.matches(number, options: [option1], range: NSRange(location: 0, length: 1)))

          for option2 in matchingOptions.elements() {
            XCTAssertTrue(regex.matches(number, options: [option2]))
            XCTAssertTrue(regex.matches(number, options: [option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertFalse(regex.matches(number, options: [option2], range: NSRange(location: 0, length: 1)))

            XCTAssertTrue(regex.matches(number, options: [option1, option2]))
            XCTAssertTrue(regex.matches(number, options: [option1, option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertFalse(regex.matches(number, options: [option1, option2], range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  func testMatchesWithReservedNumbers() {
    for `case` in VSRegexPattern.allCases {
      let regex = VSRegex(`case`)
      XCTAssertNotNil(regex)

      for number in TestDataFetcher.shared.reservedNumbers {
        XCTAssertFalse(regex.matches(number))
        XCTAssertFalse(regex.matches(number, range: NSRange(location: 0, length: number.count)))
        XCTAssertFalse(regex.matches(number, range: NSRange(location: 0, length: 1)))

        for option1 in matchingOptions.elements() {
          XCTAssertFalse(regex.matches(number, options: [option1]))
          XCTAssertFalse(regex.matches(number, options: [option1], range: NSRange(location: 0, length: number.count)))
          XCTAssertFalse(regex.matches(number, options: [option1], range: NSRange(location: 0, length: 1)))

          for option2 in matchingOptions.elements() {
            XCTAssertFalse(regex.matches(number, options: [option2]))
            XCTAssertFalse(regex.matches(number, options: [option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertFalse(regex.matches(number, options: [option2], range: NSRange(location: 0, length: 1)))

            XCTAssertFalse(regex.matches(number, options: [option1, option2]))
            XCTAssertFalse(regex.matches(number, options: [option1, option2], range: NSRange(location: 0, length: number.count)))
            XCTAssertFalse(regex.matches(number, options: [option1, option2], range: NSRange(location: 0, length: 1)))
          }
        }
      }
    }
  }

  /// These wrappers only need a simple test.
  func testStaticWrappers() {
    let phoneNumber = "13800138000"
    XCTAssertTrue(VSRegex.matches(phoneNumber))
    XCTAssertTrue(VSRegex.matches(phoneNumber, in: .carrier(.chinaMobile)))
    XCTAssertTrue(
      VSRegex.matches(phoneNumber,
                      in: .carrier(.chinaMobile),
                      matchingOptions: matchingOptions,
                      range: NSRange(location: 0, length: 11))
    )
    XCTAssertFalse(
      VSRegex.matches(phoneNumber,
                      in: .carrier(.chinaMobile),
                      regularExpressionOptions: regularExpressionOptions,
                      matchingOptions: matchingOptions,
                      range: NSRange(location: 0, length: 11))
    )

    XCTAssertTrue(VSRegex.is(phoneNumber, matches: .all))
    XCTAssertTrue(
      VSRegex.is(phoneNumber,
                 matches: .carrier(.chinaMobile),
                 matchingOptions: matchingOptions,
                 range: NSRange(location: 0, length: 11))
    )
    XCTAssertFalse(
      VSRegex.is(phoneNumber,
                 matches: .carrier(.chinaMobile),
                 regularExpressionOptions: regularExpressionOptions,
                 matchingOptions: matchingOptions,
                 range: NSRange(location: 0, length: 11))
    )
  }
}
