# RbxMouse
A clean mouse library using up-to-date input APIs. Only works on the client.

# API
## Mouse Object
This library returns a `Mouse` object which can be used similar to the official deprecated `Mouse` object.

```lua
local Mouse = require(script.RbxMouse)
```

Certain features will only start running if used (e.g. `Mouse.CFrame` is indexed).

## Properties
This `Mouse` object has a lot of similar properties. The CFrame and Target properties will not be up

### *Vector2* Position
The 2D position of the mouse.

### *CFrame* CFrame
The 3D position and direction of the mouse (see Configuration & `Mouse:SetRayDistance()`).

### *BasePart/nil* Target
The part the mouse is over (see Constants).

## Signals
The `Mouse` object contains signals that can be treated exactly like `RbxScriptSignals`.

There are three signals for every mouse button:
- Button`X`Down
- Button`X`Up
- Button`X`Click

The `ButtonXClick` event will fire if `ButtonXUp` is fired less than or exactly 0.5 seconds after `ButtonXDown` (see Constants).

Example usage:
```lua
Mouse.Button1Down:Connect(function()
  print("Left mouse button is down!")
end)

local Button3ClickConnection = Mouse.Button3Click:Connect(function()
  print("Middle mouse button has been clicked!")
end)

Mouse.Button2Up:Wait()

Button3ClickConnection:Disconnect()
```

## Methods
The `Mouse` object has a number of methods for different features.

### *void* Mouse:Pause ( )
Disconnects the `Mouse` object from all input signals. Useful if you want to disable mouse input detection.

### *void* Mouse:Resume ( )
Reconnects the `Mouse` object to all input signals.

### *void* Mouse:Hide ( )
Hides the mouse. Only needs to be called once.

### *void* Mouse:Show ( )
Shows the mouse. Only needs to be called once.

### *void* Mouse:SetClickThreshold ( *<number>* ClickThreshold )
  The threshold for firing a click event between mouse down and up events. Defaults to `0.5`.

### *void* Mouse:SetRayDistance ( *<number>* RayDistance )
  The limit of mouse CFrame and Target detection. Defaults to `1000`.

## Children
Child objects that can be indexed using `Mouse.ChildName`.

### TargetFilter
Object that holds four methods for manipulating the filter for the `Mouse.Target` property:

  - *array<Instance>* TargetFilter:Get ()
  - *void* TargetFilter:Set ( *\<array\<Instance\>/Instance/nil\>* IgnoreDescendantsInstance )
  
  - *void* TargetFilter:Add ( *\<Instance\>* IgnoreDescendantsInstance )
  - *void* TargetFilter:Remove ( *\<Instance\>* IgnoreDescendantsInstance )
  
### Icon
Object that holds two methods for manipulating the mouse icon:

  - *void/string* Icon:Get ()
  - *void* Icon:Set ( *<int/string>* AssetId )

## Constants
Must be edited manually.

### *number* DEFAULT_CLICK_TIMEOUT
The threshold for firing a click event between mouse down and up events. Defaults to `0.5`. Custom click timeout can be set at runtime with `Mouse:SetClickThreshold()`.

### *number* DEFAULT_RAY_DISTANCE
The limit of mouse CFrame and Target detection. Defaults to `1000`. Custom ray distance can be set at runtime with `Mouse:SetRayDistance()`.
