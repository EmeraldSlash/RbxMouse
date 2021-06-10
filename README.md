# RbxMouse v3.1

A clean mouse library using up-to-date input and raycasting APIs. Only works on the client, and there should only be one instance of this object running at one point in time.

```lua
local RbxMouse = require(script.RbxMouse)
```

A basic first person camera system example:
```lua
local SENSITIVITY = 0.001
local MIN_Y = -math.pi/2.1
local MAX_Y = math.pi/2.1

local camera = workspace.CurrentCamera
local angleX = 0
local angleY = 0

RbxMouse:SetUpdateMode(RbxMouse.UPDATE_RENDER)
-- With mode set to UPDATE_RENDER, there is no need to set this every frame
RbxMouse:SetBehavior(Enum.MouseBehavior.LockCenter)
-- Hide mouse icon
RbxMouse:SetVisible(false)

RbxMouse.Move:Connect(function(delta)
	-- Use mouse delta (which is in pixel units) to modify camera angle
	angleX = angleX - (delta.X * SENSITIVITY)
	angleY = math.clamp(angleY - (delta.Y * SENSITIVITY), MIN_Y, MAX_Y)
end)

game:GetService("RunService").RenderStepped:Connect(function()
	local character = game.Players.LocalPlayer.Character
	if character then
		local head = character:FindFirstChild("Head")
		if head then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.Focus = CFrame.new(head.Position)
			local cf = CFrame.fromEulerAnglesXYZ(
				angleY,
				angleX,
				0
			)
			camera.CFrame = CFrame.fromMatrix(
				head.Position, 
				cf.XVector,
				cf.YVector,
				cf.ZVector
			)
		else
			camera.CameraType = Enum.CameraType.Custom
		end
	else
		camera.CameraType = Enum.CameraType.Custom
	end
end)
```

A realllly basic gun system example:
```lua
-- If gameProcessedEvent is true, don't fire input events
RbxMouse.IgnoreButtonInputWhenGameProcessed = true
-- Ignore parts with Transparency >= 1 or CanCollide == false
RbxMouse.RaycastMethod = RbxMouse.RAYCAST_FILTER_TRANSPARENT_COLLIDABLE

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RbxMouse.RaycastParams = raycastParams

RbxMouse.Button1Down:Connect(function()
	-- Cast a ray and get hit part, position, normal and material
	local targetResult = RbxMouse:UpdateTarget()
	if targetResult and targetResult.Instance then
		local targetPlayer = game.Players:GetPlayerFromCharacter(targetResult.Instance.Parent)
		if targetPlayer then
			print(("Hit part %s (of player %s)"):format(targetResult.Instance.Name, targetPlayer.Name))
		-- Then you might call something like:
		-- game.ReplicatedStorage.HitPlayer:FireServer(targetPlayer, targetResult.Position)
		else
			print(("Hit part %s"):format(targetResult.Instance.Name))
		end
	end
end)
```

# API Reference
? means a value can be nil or is optional
	
## Properties

#### *Vector2* Position
The 2D position of the mouse on the screen, ignoring GUI inset.

#### *Vector2* InsetPosition
Same as above but it accounts for the GUI inset.

#### *Ray* Ray
Unit ray going from Camera in the direction of the mouse. Essentially `Camera:ScreenPointToRay`.

#### *<RaycastResult,table,nil>* Target
The container for the target Instance, Position, Normal and Material. This will always be a RaycastResult instance, unless nothing was hit or a custom raycast method was used which returned a table instead.

#### *<BasePart,nil>* TargetInstance
The Target's Instance value, or nil if Target is nil (for quality of life).

#### *bool* MapTouchToMouse
If set to true, touch input will fire the Button1* and Move signals.

#### *float* MaxClickTime
Button*Clicked signals will not fire if the buttons were held down for longer than this number of seconds.

#### *bool* IgnoreButtonInputWhenGameProcessed
If set to true, Button* signals will not fire if gameProcessedEvent is true.

#### *bool* IgnoreMotionInputWhenGameProcessed
If set to true, Move and Wheel* signals will not fire if gameProcessedEvent is true.

#### *bool* DoesRayUseInset
If set to true, UpdateRay will use RbxMouse.InsetPosition and will account for this when creating the ray.

#### *bool* DoesRayUpdateWithTarget
If set to true, UpdateRay will be called every time UpdateTarget is called.

#### *RaycastParams* RaycastParams
The RaycastParams (FilterType, FilterList, IgnoreWater) to be passed to the raycast method.

#### *float* RaycastDistance
The maximum distance a mouse hit can be from the camera.

#### *RbxMouse.RAYCAST_\** RaycastMethod
The method to use when finding the mouse hit data (part, position, normal, material) in the world.

**RAYCAST_BASIC**: `Workspace:Raycast()` with RaycastParams
**RAYCAST_FILTER_TRANSPARENT**: Same as RAYCAST_BASIC but it ignores transparent parts.
**RAYCAST_FILTER_COLLIDABLE**: Same as RAYCAST_BASIC but it ignores parts with CanCollide set to false.
**RAYCAST_FILTER_TRANSPARENT_COLLIDABLE**: Combines both of the above.
**RAYCAST_CUSTOM**: Uses a custom provided function or `RbxMouse.CustomRaycastFunction` to find the mouse target.

#### *function<RaycastResult>* CustomRaycastFunction ( *Vector3* origin, *Vector3* direction, *RaycastParams* raycastParams, ... )
The function to use to find the mouse target. It should return RaycastResult or a table with the same members as RaycastResult. It can also take any number of additional parameters, which may be given when calling RbxMouse:UpdateTarget().
	
## Signals
Can be fired manually with RbxMouse:Fire<EventName>(), you can give any arguments.

Example: `RbxMouse:FireButton1Click(0.5, true, workspace.Baseplate.Color)`

#### Button1Down ( *bool* gameProcessed, *bool* wasTouch )
#### Button1Up ( *bool* gameProcessed, *bool* wasTouch )
#### Button1Click ( *float* timeSpentDown, *bool* gameProcessed, *bool* wasTouch )
#### Button2Down ( *bool* gameProcessed )
#### Button2Up ( *bool* gameProcessed )
#### Button2Click ( *float* timeSpentDown, *bool* gameProcessed )
#### Button3Down ( *bool* gameProcessed )
#### Button3Up ( *bool* gameProcessed )
#### Button3Click ( *float* timeSpentDown, *bool* gameProcessed )
#### WheelDown (*bool* gameProcessed )
#### WheelUp ( *bool* gameProcessed )
#### WheelScroll ( *int* direction, *bool* gameProcessed )
#### Move ( *Vector2* delta, *bool* gameProcessed )
#### RayUpdate ( *Vector3* ray )
#### TargetUpdate ( *<RaycastResult,table,nil>* target, *<BasePart,nil>* targetInstance )

## Methods

#### *Ray* UpdateRay ( *?Vector2* customPosition, *?bool* customWithInset )
Creates, updates and returns a new unit ray from the camera in the direction of the mouse. Can take a custom mouse position and whether position has GUI inset already applied to it or not (if true, will use `Camera:ScreenPointToRay` instead of `Camera:ViewportPointToRay`).
		
#### *<RaycastResult,table,nil>, <BasePart,nil>* UpdateTarget ( *?RaycastParams* customRaycastParams, *?float* customRaycastDistance, *?<RbxMouse.RAYCAST_*,function>* customRaycastMethod, *?bool* AlsoUpdateRay, <Arguments to raycast method> ... )
Performs a raycast using the default or given raycast method and updates and returns RbxMouse's Target and TargetInstance properties. If customRaycastMethod is a function it will perform the raycast using the function instead of using one of the enum methods, and has the same signature as RbxMouse.CustomRaycastFunction. Additional parameters will be passed to the raycast method.
	
#### *RbxMouse.UPDATE_\** GetUpdateMode()
#### *void* SetUpdateMode ( *RbxMouse.UPDATE_\** updateMode )
Sets the current property update mode. This controls whether things like MouseBehavior will override the UserInputService property every frame by RbxMouse (by calling UpdateBehavior) or whether that has to be manually done by the user.

**UPDATE_MANUAL**: Has to be manually updated using the `RbxMouse:Set*()` methods
**UPDATE_RENDER**: Updates every frame using `RunService.RenderStepped`.

#### *RbxMouse.TARGET_\** GetTargetMode ()
#### *void* SetTargetMode ( *RbxMouse.TARGET_\** targetMode )
Sets the current target update mode. This controls where and how the mouse Target and Ray will be updated.

**TARGET_MANUAL**: Has to be manually updated using the `RbxMouse:Update*()` methods.
**TARGET_MOVEMENT**: Only updates when the mouse moves.
**TARGET_RENDER**: Updates every frame using `RunService.RenderStepped.`

#### *bool* GetBehavior ( *bool* getRawUserInputValue )
Does not get raw value by default as it may give an inaccurate value if update mode is set to UPDATE_RENDER and this gets called before RbxMouse is able undo the UIS reset every frame.

#### *void* SetBehavior ( *MouseBehavior* behaviour )
Sets the current mouse behavior. If update mode is UPDATE_RENDER, this value will persist and will not get reset like it does when using UIS.

#### *bool* GetVisible ()
#### *void* SetVisible ( *bool* visible )
Sets whether mouse icon is currently visible. Equivalent to `UIS.MouseIconEnabled`.

#### *bool* GetSensitivity ()
#### *void* SetSensitivity ( *float* sensitivity )
Sets the mouse sensitivity. Equivalent to `UIS.MouseDeltaSensitivity`.

#### string GetIcon ()
#### *void* SetIcon ( *string* assetUrl )
Sets the current mouse icon to an image with this asset URL. Equivalent to Mouse.Icon.

#### *bool* GetEnabled ()
#### *void* SetEnabled ( *bool* enabled )
Sets whether mouse signals will be fired and render updates will occur. Useful if you want to temporarily disable the whole mouse without breaking your connections.
		
#### *Vector2* GetDelta ()
Retrives the mouse delta since the last frame but only if mouse is locked. Equivalent to `UIS:GetMouseDelta()`.
				
#### *array(InputObject)* GetButtonsPressed ()
Returns an array of InputObjects corresponding with the mouse buttons currently being held down. Equivalent to `UIS:GetMouseButtonsPressed()`.
				
#### *bool* IsButtonPressed ( *UserInputType* mouseButton )
Returns whether the given mouse button is currently being held down. Equivalent to `UIS:IsMouseButtonPressed()`.
			
#### *variant* Get<PropertyName> ()
#### *void* Set<PropertyName> ( *variant* value )
Allows you to use getter and setter functions on the other properties of RbxMouse. Using these methods is not required and are just here for your convenience.
