# SafetyCode

Safety Code is free to use. The package tracks the visitors’ GPS position and determines if they are driving. If going faster than 20 km/h, they will need to confirm that they are not the driver to continue useing the app.

## Usage

```swift
safetyCode = SafetyCode()
```

Initialize with custom messages:

```swift
safetyCode = SafetyCode(options: [
    "title" : "Oops! Du kör väl inte bil?",
    "message" : "Den här sidan är fartspärrad för din egen säkerhet",
    "actionTitle" : "Jag är inte föraren"
])
```
