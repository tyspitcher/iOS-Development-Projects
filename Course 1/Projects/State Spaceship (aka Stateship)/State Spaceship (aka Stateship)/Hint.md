#  Hints

// notes: @State is used within an object to check on any changes
// @Binding is used for when you want to pass it down only one layer
// you have to mark the variable you want to pass with a $ in the parent
// and access it with @Binding in the area you want to access it
// @Environment is used to access it in the area you want to access it,
// and you use .environment to pass it from the parent
## Hint for accessing an environment variable:

As long as only one variable of a given type exists, you can get that variable just by stating its type. So in this case, you can do:
`@Environment(ShipComputer.self) var shipComputer`

## Hint for WeaponsSystem toggle behavior:

Add or remove power when the toggle is changed. After changing the ship's available power, check to see whether we've exceeded power. If so, turn it back off. You can use .onChange or didSet, but .onChange is the more typical SwiftUI approach.
```
    .onChange(of: isOn) {
        if isOn {
            shipComputer.availablePower += 3
        } else {
            shipComputer.availablePower -= 3
        }
        
        if shipComputer.availablePower > 10 {
            isOn = false
        }
    }
```

## Hint for Shield and EngineSystem Stepper behavior:

Add or remove power when the stepper's value is changed. After changing the ship's available power, check to see whether we've exceeded power. If so, step it back down. You can use .onChange or didSet, but .onChange is the more typical SwiftUI approach.
```
    .onChange(of: powerUsed) { oldValue, newValue in
        let difference = newValue - oldValue
        
        shipComputer.availablePower -= difference
        
        if shipComputer.availablePower < 0 {
            powerUsed = oldValue
        }
    }
```

## Hint for enabling/disabling stations based on whether they're manned

You can simply attach a .disabled to each of the controls on the station and simply wire it to your `@State var inChair` properties (which you should have set up in the previous step).

```
.disabled(!inChair)
```
