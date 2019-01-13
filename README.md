# VSRegex

[ChinaMobilePhoneNumberRegex] wrappers for iOS and macOS in Swift.

## Usage

```swift
let regex = VSRegex() // Match all numbers by default.
let isMatch = regex.matches("+8613800138000")
print(isMatch) // true


let regex = VSRegex(.carrier(.chinaTelecom))
let isMatch = regex.matches("+8613800138000")
print(isMatch) // false

    
let isMatch = VSRegex.matches("+8613800138000")
print(isMatch) // true

    
let isMatch = VSRegex.is("+8613800138000", matches: .carrier(.chinaMobile))
print(isMatch) // true

...
```

## Installation

### CocoaPods

```
pod 'VSRegex', '~> 1.0.0'
```

## License

MIT

[ChinaMobilePhoneNumberRegex]: https://github.com/VincentSit/ChinaMobilePhoneNumberRegex

