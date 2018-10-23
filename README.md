# RbxMouse v2.0
A clean mouse object using up-to-date input APIs. Only works on the client, and there should only be one instance of this object running at one point in time.

The mouse object can be configured in the Configuration module. This will allow you to disable things such as the Target property and the RbxTargetFilter object, and change values such as the length of the ray being cast for the CFrame and Target properties.

Example usage:

```lua
local Mouse = require(script.RbxMouse)

Mouse.TargetFilter:Add(workspace.Part)
Mouse.Icon:Set(12345678)

local leftMouseButton = Mouse.Button[1]
leftMouseButton.Down:Connect(function()
    print("Left mouse button pressed!")
end

local rightMouseButton = Mouse.Button.Right
rightMouseButton.Click:Connect(function(timeSpentDown))
    print("Right mouse button clicked!")
end

Mouse.Move:Connect(function(newPosition)
    print("Left mouse button is down =", leftMouseButton.IsDown)
    print("Current mouse target is", Mouse.Target)
end
```

# API Reference
## RbxMouse
This module returns a `RbxMouse` object which can be used similar to the official `Mouse` object.

### Children
#### *RbxMouseButton* RbxMouse.Button
Object that holds 3 `RbxMouseButton` objects, one for each of the 3 buttons on a mouse.
They can be indexed either by their number (1, 2, 3) or their name/position (Left, Right, Middle).

```lua
Mouse.Button[1]
Mouse.Button.Left

Mouse.Button[2]
Mouse.Button.Right

Mouse.Button[3]
Mouse.Button.Middle
```

#### *RbxMouseIcon* RbxMouse.Icon
`RbxMouseIcon` object for the mouse.

#### *RbxTargetFilter* RbxMouse.TargetFilter
`RbxTargetFilter` for the mouse. Will throw an exception if target is disabled in configuration.

### Properties
This `Mouse` object has a lot of similar properties.

#### *Vector2* Mouse.Position
The 2D position of the mouse.

#### *CFrame* Mouse.CFrame
The 3D position and direction of the mouse.

#### *BasePart/nil* Mouse.Target
The BasePart the mouse is hovering over. Will throw an exception if target is disabled in configuration.

### Signals
#### Mouse.Move ( *Vector2* Position )
Fires every time the mouse is moved. The position of the mouse is passed to the callback function.

### Methods
#### *void* Mouse:Hide ( )
Hides the mouse icon. Only needs to be called once.

#### *void* Mouse:Show ( )
Shows the mouse icon. Only needs to be called once.

#### *void* Mouse:Disable ( )
Disconnects all input listeners without removing your connections. Useful if you want to put the Mouse's properties into a static state, or if you want to stop listening for Mouse input.

#### *void* Mouse:Enable ( )
Reconnects all input listeners.

## RbxMouseButton
A `RbxMouseButton` objects represents one of the buttons on a mouse.

### Properties
#### *bool* RbxMouseButton.IsDown
Whether the button is being pressed or not.

### Signals
#### RbxMouseButton.Down ( )
Fired when the button is pressed.

#### RbxMouseButton.Up ( )
Fired when the button is released.

#### RbxMouseButton.Click ( *number* TimeSpentDown )
Fired when the button is released if the time the button was spent down was smaller than or equal to the click threshold (defaults to 0.5 seconds, can be configured in the configuration module).

### Methods
#### *void* RbxMouseButton:ForceDown ( )
Forces the button to be pressed. The button will still be considered released when the user stops pressing the button.

#### *void* RbxMouseButton:ForceUp ( )
Forces the button to be released. The button will still be considered pressed when the user presses the button.

## RbxMouseIcon
A `RbxMouseIcon` object is responsible for the mouse icon.

### Methods
#### *void* RbxMouseIcon:Show ( )
Shows the mouse icon. Only needs to be called once.

#### *void* RbxMouseIcon:Hide ( )
Hides the mouse icon. Only needs to be called once.

#### *void* RbxMouseIcon:Set ( *int/string* AssetId )
Sets the mouse icon to an image asset path. If `AssetId` is an int, it will convert it into a valid path before setting it. Call it with nil or an empty string to reset the icon.

#### *void* RbxMouseIcon:Get ( )
Returns the current mouse icon asset ID. Returns an empty string if it has not been set.

## RbxTargetFilter
A `RbxTargetFilter` objects is responsible for managing the objects in the mouse's target filter. A target filter is an array that cannot hold more than one reference to the same `Instance` at the same time.

### Methods
#### *void* RbxTargetFilter:Set ( *array<Instance>/Instance* Objects )
Sets the target filter to an array (overwriting the old target filter). If the `Object` argument is an `Instance`, it will create an array and insert the `Instance` into the array. If there are duplicate references, only one will be used.

#### *array<Instance>* RbxTargetFilter:Get ( )
Returns the array of objects in the target filter.

#### *void* RbxTargetFilter:Add ( *Instance* Object )
Adds an object into the target filter. If this will cause duplicate references, it will not be added.

#### *void* RbxTargetFilter:Remove ( *Instance* Object )
Removes an instance from the target filter.
