# RbxMouse
A clean mouse library using up-to-date input APIs. Only works on the client.

## API
### Mouse Object
This library returns a `Mouse` object which can be used similar to the official deprecated `Mouse` object.

```lua
local Mouse = require(script.RbxMouse)
```

### Properties
This `Mouse` object has a lot of similar properties. I am intending to make it so that these properties will not be updated until they have been used.

**TO DO EVERYTHING HERE**

#### *Vector2* Position
The 2D position of the mouse.

#### *CFrame* CFrame
The 3D position and direction of the mouse.

#### *BasePart* Target
The part the mouse is over.

### Signals
The `Mouse` object contains signals that can be treated exactly like `RbxScriptSignals`.

There are three signals for every mouse button:
- Button`X`Down
- Button`X`Up
- Button`X`Click

The `ButtonXClick` event will fire if `ButtonXUp` is fired less than or exactly 0.5 seconds after `ButtonXDown`. This length can be modified in the library during runtime through the `SetClickTimeout` method or through changing the `DEFAULT_CLICK_TIMEOUT` variable in the source code.

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

### Methods
The `Mouse` object has a number of methods for different features.

#### *void* Mouse:Pause ( )
Disconnects the `Mouse` object from all input signals. Useful if you want to disable mouse input detection.

#### *void* Mouse:Resume ( )
Reconnects the `Mouse` object to all input signals.

#### *void* Mouse:Hide ( )
Hides the mouse icon. Only needs to be called once.

#### *void* Mouse:Show ( )
Shows the mouse icon. Only needs to be called once.

#### *void* Mouse:SetTargetFilter ( *<function/nil>* FilterFunction )
Sets the function used to filter the `Target` property. If the `FilterFunction` argument is nil, it will remove the custom function and return the target filtering to its default state.

##### *bool* FilterFunction ( *BasePart* Part )
The filter function should return whether `Part` is able to be represented in the `Target` property.

#### *void* SetIcon ( *<string/integer/nil>* AssetId )
Sets the mouse icon to `AssetId`. Can be a full Roblox asset path, an asset ID on its own. If given nil, the icon is returned to its default.
