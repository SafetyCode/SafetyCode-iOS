# SafetyCode

Help make life on the road safer by using Safety Code – a free package that will block your app for all users while driving a car.

Safety Code is free and can be used in any app. The code tracks the visitors’ GPS position and determines if they are driving. If going faster than 20 km/h, they will need to confirm that they are not the driver to continue using the app.


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
