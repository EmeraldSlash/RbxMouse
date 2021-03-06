-- A clean mouse library that uses up-to-date APIs
-- Can be loaded using the Rostrap library manager
-- @version 3.1
-- @author EmeraldSlash
-- @repository https://github.com/EmeraldSlash/RbxMouse

local DEFAULT_SETTINGS = {
	MapTouchToMouse = true;
	MaxClickTime = math.huge;
	IgnoreButtonInputWhenGameProcessed = false;
	IgnoreMotionInputWhenGameProcessed = false;
	DoesRayUseInset = false;
	DoesRayUpdateWithTarget = true;
	RaycastParams = RaycastParams.new();
	RaycastDistance = 1024;
	RaycastMethod = "Basic";
	CustomRaycastFunction = nil;
}

--[[

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

--]]

local RbxMouse = {

	RAYCAST_BASIC = "Basic";
	RAYCAST_FILTER_TRANSPARENT = "FilterTransparent";
	RAYCAST_FILTER_COLLIDABLE = "FilterCollidable";
	RAYCAST_FILTER_TRANSPARENT_COLLIDABLE = "FilterTransparentCollidable";
	RAYCAST_CUSTOM = "Custom";

	UPDATE_MANUAL = "Manual";
	UPDATE_RENDER = "Render";

	TARGET_MANUAL = "Manual";
	TARGET_MOVEMENT = "Movement";
	TARGET_RENDER = "Render";

	Position = Vector2.new();
	InsetPosition = Vector2.new();
	Ray = Ray.new(Vector3.new(), Vector3.new());
	Target = nil;
	TargetInstance = nil;

	MapTouchToMouse = DEFAULT_SETTINGS.MapTouchToMouse; -- default: true
	MaxClickTime = DEFAULT_SETTINGS.MaxClickTime; -- default: math.huge
	IgnoreButtonInputWhenGameProcessed = DEFAULT_SETTINGS.IgnoreButtonInputWhenGameProcessed; -- default: false
	IgnoreMotionInputWhenGameProcessed = DEFAULT_SETTINGS.IgnoreMotionInputWhenGameProcessed; -- default: false
	DoesRayUseInset = DEFAULT_SETTINGS.DoesRayUseInset; -- default: false
	DoesRayUpdateWithTarget = DEFAULT_SETTINGS.DoesRayUpdateWithTarget; -- default: true
	RaycastParams = DEFAULT_SETTINGS.RaycastParams; -- default: RaycastParams.new()
	RaycastDistance = DEFAULT_SETTINGS.RaycastDistance; -- default: 1024
	RaycastMethod = DEFAULT_SETTINGS.RaycastMethod; -- default: "Basic"
	CustomRaycastFunction = DEFAULT_SETTINGS.CustomRaycastFunction; -- default: nil

}

do
	local createSignal = function(name)
		local new = Instance.new("BindableEvent")
		new.Parent = script
		new.Name = name
		RbxMouse[name] = new.Event
		RbxMouse["Fire"..name] = function(self, ...)
			new:Fire(...)
		end
	end

	createSignal("Button1Down")
	createSignal("Button1Up")
	createSignal("Button1Click")
	createSignal("Button2Down")
	createSignal("Button2Up")
	createSignal("Button2Click")
	createSignal("Button3Down")
	createSignal("Button3Up")
	createSignal("Button3Click")
	createSignal("WheelDown")
	createSignal("WheelUp")
	createSignal("WheelScroll")
	createSignal("Move")
	createSignal("RayUpdate")
	createSignal("TargetUpdate")
end

local updateMode = RbxMouse.UPDATE_MANUAL
local targetMode = RbxMouse.TARGET_MANUAL
local mouseBehavior = Enum.MouseBehavior.Default
local enabled = false

local updateRenderConnection do
	local RunService = game:GetService('RunService')

	local renderFunction = function()
		if updateMode == RbxMouse.UPDATE_RENDER then
			RbxMouse:SetBehavior(mouseBehavior)
		end
		if targetMode == RbxMouse.TARGET_RENDER then
			RbxMouse:UpdateTarget()
		end
	end

	updateRenderConnection = function()
		if enabled and (updateMode == RbxMouse.UPDATE_RENDER or targetMode == RbxMouse.TARGET_RENDER) then
			RunService:BindToRenderStep("RbxMouse", Enum.RenderPriority.Camera.Value - 1, renderFunction)
		else
			RunService:UnbindFromRenderStep("RbxMouse")
		end
	end

	RbxMouse.GetUpdateMode = function()
		return updateMode
	end

	RbxMouse.GetTargetMode = function()
		return targetMode
	end

	RbxMouse.SetUpdateMode = function(self, newUpdateMode)
		updateMode = newUpdateMode
		updateRenderConnection()
	end

	RbxMouse.SetTargetMode = function(self, newTargetMode)
		targetMode = newTargetMode
		updateRenderConnection()
	end

	RbxMouse:SetUpdateMode(updateMode)
	RbxMouse:SetTargetMode(targetMode)
end

local updateInputConnections do
	local UIT = Enum.UserInputType
	local UIT_MM = UIT.MouseMovement
	local UIT_M1 = UIT.MouseButton1
	local UIT_M2 = UIT.MouseButton2
	local UIT_M3 = UIT.MouseButton3
	local UIT_MW = UIT.MouseWheel
	local UIT_T = UIT.Touch

	local inputStart = {}

	local processButtonDown = function(uit, gameProcessed)
		if not inputStart[uit] then
			inputStart[uit] = tick()
		end
		if uit == UIT_M1 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			RbxMouse:FireButton1Down(gameProcessed, uit == UIT_T)
		elseif uit == UIT_M2 then
			RbxMouse:FireButton2Down(gameProcessed)
		elseif uit == UIT_M3 then
			RbxMouse:FireButton3Down(gameProcessed)
		end
	end

	local processButtonUp = function(uit, gameProcessed)
		local currentInputStart = inputStart[uit]
		inputStart[uit] = nil
		local currentTime = tick()
		if uit == UIT_M1 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			RbxMouse:FireButton1Up(gameProcessed, uit == UIT_T)
		elseif uit == UIT_M2 then
			RbxMouse:FireButton2Up(gameProcessed)
		elseif uit == UIT_M3 then
			RbxMouse:FireButton3Up(gameProcessed)
		end
		if currentInputStart then
			local timeSpentDown = currentTime - currentInputStart
			if timeSpentDown > 0 and timeSpentDown < RbxMouse.MaxClickTime then
				if uit == UIT_M1 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
					RbxMouse:FireButton1Click(timeSpentDown, gameProcessed, uit == UIT_T)
				elseif uit == UIT_M2 then
					RbxMouse:FireButton2Click(timeSpentDown, gameProcessed)
				elseif uit == UIT_M3 then
					RbxMouse:FireButton3Click(timeSpentDown, gameProcessed)
				end
			end
		end
	end

	local processMovement = function(uit, position, delta, gameProcessed)
		local topLeftInset = game:GetService('GuiService'):GetGuiInset()
		RbxMouse.InsetPosition = Vector2.new(position.X, position.Y)
		RbxMouse.Position = RbxMouse.InsetPosition + topLeftInset
		if targetMode == RbxMouse.TARGET_MOVEMENT then
			RbxMouse:UpdateTarget()
		end
		RbxMouse:FireMove(delta, gameProcessed, uit == UIT_T)
	end

	local processScroll = function(scroll, gameProcessed)
		if scroll > 0 then
			RbxMouse:FireWheelUp(gameProcessed)
		else
			RbxMouse:FireWheelDown(gameProcessed)
		end
		RbxMouse:FireWheelScroll(scroll, gameProcessed)
	end

	local inputBegan = function(input, gameProcessed)
		local uit = input.UserInputType
		if uit == UIT_M1 or uit == UIT_M2 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			if not gameProcessed or not RbxMouse.IgnoreButtonInputWhenGameProcessed then
				processButtonDown(uit, gameProcessed)
			end
		end
	end

	local inputEnded = function(input, gameProcessed)
		local uit = input.UserInputType
		if uit == UIT_M1 or uit == UIT_M2 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			if not gameProcessed or not RbxMouse.IgnoreButtonInputWhenGameProcessed then
				processButtonUp(uit, gameProcessed)
			end
		end
	end

	local inputChanged = function(input, gameProcessed)
		local uit = input.UserInputType
		if uit == UIT_MM or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			if not gameProcessed or not RbxMouse.IgnoreMotionInputWhenGameProcessed then
				processMovement(uit, input.Position, input.Delta, gameProcessed)
			end
		elseif uit == UIT_MW then
			if not gameProcessed or not RbxMouse.IgnoreMotionInputWhenGameProcessed then
				processScroll(input.Position.Z, gameProcessed)
			end
		end
	end

	local UserInputService = game:GetService("UserInputService")
	local inputConnections = {}

	updateInputConnections = function()
		for i = 1, #inputConnections do
			inputConnections[i]:Disconnect()
		end
		inputConnections = {}

		if enabled then
			table.insert(inputConnections, UserInputService.InputBegan:Connect(inputBegan))
			table.insert(inputConnections, UserInputService.InputEnded:Connect(inputEnded))
			table.insert(inputConnections, UserInputService.InputChanged:Connect(inputChanged))
		end
	end

	RbxMouse.GetBehavior = function(self, raw)
		return (raw and UserInputService.MouseBehavior) or mouseBehavior
	end
	RbxMouse.SetBehavior = function(self, newMouseBehavior)
		mouseBehavior = newMouseBehavior
		UserInputService.MouseBehavior = mouseBehavior
	end

	RbxMouse.GetVisible = function()
		return UserInputService.MouseIconEnabled
	end
	RbxMouse.SetVisible = function(self, newVisible)
		UserInputService.MouseIconEnabled = newVisible
	end

	RbxMouse.GetSensitivity = function()
		return UserInputService.MouseDeltaSensitivity
	end
	RbxMouse.SetSensitivity = function(sensitivity)
		UserInputService.MouseDeltaSensitivity = sensitivity
	end

	RbxMouse.GetDelta = function(self)
		return UserInputService:GetMouseDelta()
	end

	RbxMouse.GetButtonsPressed = function(self)
		return UserInputService:GetMouseButtonsPressed()
	end

	RbxMouse.IsMouseButtonPressed = function(self, mouseButton)
		return UserInputService:IsMouseButtonPressed(mouseButton)
	end
end

do
	local Camera = workspace.CurrentCamera

	local deepCast = function(origin, direction, raycastParams, filterTransparency, filterCollide, singleUse)		
		--  NOTE: Copy the RaycastParams so that caller's filter list will not be mutated
		--		(useful if the raycast is meant to be called multiple times)
		if not singleUse then
			local newParams = RaycastParams.new()
			newParams.FilterType = raycastParams.FilterType
			newParams.IgnoreWater = raycastParams.IgnoreWater
			local newFilterList = {}
			for i = 1, #raycastParams.FilterDescendantsInstances do
				newFilterList[i] = raycastParams.FilterDescendantsInstances[i]
			end
			newParams.FilterDescendantsInstances = newFilterList
			raycastParams = newParams
		end

		local target = origin + direction
		local isBlacklist = raycastParams.FilterType == Enum.RaycastFilterType.Blacklist
		local i = 0
		while true do
			i+=1
			local result = workspace:Raycast(origin, target - origin, raycastParams)
			if result and result.Instance then
				local part = result.Instance
				if (not part:IsA("BasePart")) or (
					(not filterTransparency or part.Transparency < 1) and
						(not filterCollide or part.CanCollide)
					) then
					return result
				else
					origin = result.Position
					if isBlacklist then
						local filterInstances = raycastParams.FilterDescendantsInstances
						table.insert(filterInstances, part)
						raycastParams.FilterDescendantsInstances = filterInstances
					else
						local filterInstances = raycastParams.FilterDescendantsInstances
						local partIndex = table.find(filterInstances, part)
						if partIndex then
							table.remove(filterInstances, partIndex)
							raycastParams.FilterDescendantsInstances = filterInstances
						end
					end
				end
			else
				return nil
			end
		end
	end

	RbxMouse.UpdateRay = function(self, customPosition, customWithInset)
		local useInset = customWithInset or (RbxMouse.DoesRayUseInset and customWithInset ~= false)
		local position = customPosition or (useInset and RbxMouse.InsetPosition) or RbxMouse.Position
		local method = (useInset and Camera.ScreenPointToRay) or Camera.ViewportPointToRay
		RbxMouse.Ray = method(Camera, position.X, position.Y).Unit
		RbxMouse:FireRayUpdate(RbxMouse.Ray)
		return RbxMouse.Ray
	end

	RbxMouse.UpdateTarget = function(self, customParams, customMethod, customDistance, customUpdateRay, ...)
		local raycastParams = customParams or RbxMouse.RaycastParams
		local raycastMethod = customMethod or RbxMouse.RaycastMethod
		local raycastDistance = customDistance or RbxMouse.RaycastDistance
		local ray =
			(customUpdateRay ~= nil and ((customUpdateRay and RbxMouse:UpdateRay()) or RbxMouse.Ray)) or
			(RbxMouse.DoesRayUpdateWithTarget and RbxMouse:UpdateRay()) or
			RbxMouse.Ray
		local raycastResult
		if raycastMethod == RbxMouse.RAYCAST_BASIC then
			raycastResult = workspace:Raycast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastParams
			)
		elseif raycastMethod == RbxMouse.RAYCAST_FILTER_TRANSPARENT then
			raycastResult = deepCast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastParams,
				true,
				false,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_FILTER_COLLIDABLE then
			raycastResult = deepCast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastParams,
				false,
				true,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_FILTER_TRANSPARENT_COLLIDABLE then
			raycastResult = deepCast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastParams,
				true,
				true,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_CUSTOM or type(raycastMethod) == "function" then
			local raycastFunction =
				((type(raycastMethod) == "function") and raycastMethod)
				or RbxMouse.CustomRaycastFunction
			raycastResult = raycastMethod(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastParams,
				...
			)
		end
		RbxMouse.Target = raycastResult
		RbxMouse.TargetInstance = (raycastResult and raycastResult.Instance) or nil
		RbxMouse:FireTargetUpdate(RbxMouse.Target, RbxMouse.TargetInstance)
		return RbxMouse.Target, RbxMouse.TargetInstance
	end
end

do
	local Mouse = game:GetService("Players").LocalPlayer

	RbxMouse.SetIcon = function(asset)
		Mouse.Icon = asset
	end

	RbxMouse.GetIcon = function()
		return Mouse.Icon
	end
end

do
	RbxMouse.GetEnabled = function()
		return enabled
	end

	RbxMouse.SetEnabled = function(newEnabled)
		if newEnabled ~= enabled then
			enabled = newEnabled
			updateInputConnections()
			updateRenderConnection()
		end
	end
end

local propertySetterCache = {}
local propertyGetterCache = {}
local thingsThatCanBeNil = {"Target", "TargetInstance", "CustomRaycastFunction"}
setmetatable(RbxMouse, {
	__index = function(self, index)
		if type(index) == "string" then
			local setProperty = string.match(index, "Set(%w+)")
			if setProperty and RbxMouse[setProperty] then
				if not propertySetterCache[setProperty] then
					propertySetterCache[setProperty] = function(self, value)
						RbxMouse[setProperty] = value
					end
				end
				return propertySetterCache[setProperty]
			end
			local getProperty = string.match(index, "Get(%w+)")
			if getProperty and RbxMouse[getProperty] then
				if not propertyGetterCache[getProperty] then
					propertyGetterCache[getProperty] = function(self)
						return RbxMouse[getProperty]
					end
				end
				return propertyGetterCache[getProperty]
			end
			if not table.find(thingsThatCanBeNil, index) then
				error("'"..tostring(index).."' is not a valid member of RbxMouse.")
			end
		elseif not table.find(thingsThatCanBeNil, index) then
			error(tostring(index).." is not a valid member of RbxMouse.")
		end
	end,
	__newindex = function(self, index, value)
		if not table.find(thingsThatCanBeNil, index) then
			if type(index) == "string" then
				index = "'"..index.."'"
			end
			error("You cannot create new member "..tostring(index).." of RbxMouse.")
		end
		rawset(self, index, value)
	end
})

enabled = false
RbxMouse:SetEnabled(true)

return RbxMouse
