-- A custom mouse library that uses up-to-date APIs
-- Can be loaded using the Rostrap library manager
-- @author EmeraldSlash
-- @repository https://github.com/EmeraldSlash/RbxMouse

--[[

	API:
		? means a value can be nil or is optional
	
		Properties:
			Vector2 Position
				"The 2D position of the mouse on the screen."
			CFrame CFrame
				"The CFrame of the mouse in the world, with the look vector being the hit normal."
			Ray Ray
				"Unit ray going from Camera in the direction of the mouse. Essentially ScreenPointToRay."
			?BasePart Target
				"The part in the world that the mouse is currently over."
			Material TargetMaterial
				"The material of the part or terrain that the mouse is currently over."
			?Table RaycastFilterList
				"The list of objects to filter with the Raycastmethod (ignore list, whitelist, custom)."
			float RaycastDistance
				"The maximum distance a mouse hit can be from the camera."
			RbxMouse.RAYCAST_* RaycastMethod
				"The method to use when finding the mouse hit data (part, position, normal, material)
				 in the world.
				 RAYCAST_BASIC: FindPartOnRay
				 RAYCAST_IGNORELIST: FindPartOnRayWithIgnoreList
				 RAYCAST_WHITELIST: FindPartOnRayWithWhiteList
				 RAYCAST_FILTER_TRANSPARENT: Ignores transparent parts.
				 RAYCAST_FILTER_COLLIDABLE: Ignores parts with CanCollide set to false.
				 RAYCAST_FILTER_TRANSPARENT_COLLIDABLE: Combines both of the above.
				 RAYCAST_CUSTOM: Uses a custom function to find the hit data."
			function CustomRaycastFunction ( Vector3 origin, Vector3 direction, ?Table filterList, ... )
				"The function to use to find the mouse hit data.
				 It should return a tuple in the form:
				 ( ?BasePart hitPart, ?Vector3 hitPosition, ?hitNormal, ?hitMaterial )"
			float MaxClickTime
				"Button*Clicked signals will not fire if the buttons were held down for
				 longer than this number of seconds."
			bool MapTouchToMouse
				"If set to true, touch input will fire the Button1* and Move signals."
			IgnoreButtonInputWhenGameProcessed
				"If set to true, Button* signals will not fire if gameProcessedEvent is true."
			IgnoreMotionInputWhenGameProcessed
				"If set to true, Move and Wheel* signals will not fire if gameProcessedEvent is true."
		
		Signals:
			"Can be fired manually with RbxMouse:Fire<EventName>(), you can give any arguments.
			 Example: RbxMouse:FireButton1Click(0.5, true, workspace.Baseplate.Color)"
			
			Button1Down ( bool gameProcessed, bool wasTouch )
			Button1Up ( bool gameProcessed, bool wasTouch )
			Button1Click ( float timeSpentDown, bool gameProcessed, bool wasTouch )
			Button2Down ( bool gameProcessed )
			Button2Up ( bool gameProcessed )
			Button2Click ( float timeSpentDown, bool gameProcessed )
			Button3Down ( bool gameProcessed )
			Button3Up ( bool gameProcessed )
			Button3Click ( float timeSpentDown, bool gameProcessed )
			Move ( Vector2 delta, bool gameProcessed )
			WheelDown (bool gameProcessed )
			WheelUp ( bool gameProcessed )
			WheelScroll ( int direction, bool gameProcessed )
		
		Methods
			?Ray UpdateRay ()
				"Updates and returns the Ray property with the latest data."
			(?BasePart, ?CFrame, ?Material) UpdateTarget ( ?float raycastDistanceOverride, ?float filterListOverride, ?<RbxMouse.RAYCAST_*,function> raycastMethodOverride )
				"Updates and returns the Target, CFrame and Material properties with the latest data."
		
TODO			string GetIcon ()
TODO			void SetIcon ( string assetUrl )
				"Sets the current mouse icon to an image with this asset URL. Equivalent to Mouse.Icon."
		
TODO			bool GetVisible ()
TODO			void SetVisible ( bool visible )
				"Sets whether mouse icon is currently visible. Equivalent to UIS.MouseIconEnabled."
		
TODO			bool GetEnabled ()
TODO			void SetEnabled ( bool enabled )
				"Sets whether mouse signals will be fired and updates will occur
				 (if update mode is not UPDATE_MANUAL). Useful if you want to temporarily
				 disable the mouse without breaking connections."
		
TODO			bool GetBehavior ()
TODO			void SetBehavior ( MouseBehavior behaviour )
				"Sets the current mouse behavior. Equivalent to UIS.MouseBehavior.
		
TODO			bool SetSensitivity ()
TODO			void SetSensitivity ( float sensitivity )
				"Sets the mouse sensitivity. Equivalent to UIS.MouseDeltaSensitivity."
		
TODO			RbxMouse.UPDATE_* GetUpdateMode ()
TODO			void SetUpdateMode ( RbxMouse.UPDATE_* )
				"Sets the current update mode. This controls where and how the mouse hit data
			 and Ray will be updated.
			 UPDATE_MANUAL: Has to be manually updated using the RbxMouse:Update*() methods.
			 UPDATE_MOVEMENT: Only updates when the mouse moves.
			 UPDATE_RENDER: Updates every frame using RunService.RenderStepped."
		
TODO			variant Get<PropertyName> ()
TODO			void Set<PropertyName> ( variant value )
				"Allows you to use getter and setter functions on the other properties
				 of RbxMouse. These are not required and will have a minor negative impact
				 on performance. This is here to provide consistency in the API, if that
				 is what you care about."
		
			Vector2 GetDelta ()
				"Retrives the mouse delta since the last frame but only if mouse is locked.
				 Equivalent to UIS:GetMouseDelta()."
			array[3](InputObject) GetButtonsPressed ()
				"Returns an array of InputObjects corresponding with the mouse buttons
				 currently being held down. Equivalent to UIS:GetMouseButtonsPressed().
			bool IsButtonPressed ( UserInputType mouseButton )
				"Returns whether the given mouse button is currently being held down.
				 Equivalent to UIS:IsMouseButtonPressed()."

--]]

local RbxMouse = {
	RAYCAST_BASIC = "Basic";
	RAYCAST_IGNORELIST = "IgnoreList";
	RAYCAST_WHITELIST = "Whitelist";
	RAYCAST_FILTER_TRANSPARENT = "FilterTransparent";
	RAYCAST_FILTER_COLLIDABLE = "FilterCollidable";
	RAYCAST_FILTER_TRANSPARENT_COLLIDABLE = "FilterTransparentCollidable";
	RAYCAST_CUSTOM = "Custom";

	UPDATE_MANUAL = "Manual";
	UPDATE_MOVEMENT = "Movement";
	UPDATE_RENDER = "Render";

	Position = Vector2.new();
	
	Ray = Ray.new(Vector3.new(), Vector3.new());
	CFrame = CFrame.new();
	Target = nil;
	TargetMaterial = nil;
	RaycastFilterList = nil;
	RaycastDistance = 1024;
	RaycastMethod = "Basic";
	CustomRaycastFunction = nil;
	
	MaxClickTime = math.huge;
	MapTouchToMouse = true;
	IgnoreButtonInputWhenGameProcessed = false;
	IgnoreMotionInputWhenGameProcessed = false;
}

local propertySetterCache = {}
local thingsThatCanBeNil = {Target = true, TargetMaterial = true, RaycastFilterList = true, CustomRaycastFunction = true}
setmetatable(RbxMouse, {
	__index = function(self, index)
		local property = string.match(index, "Set(%w+)")
		if property and RbxMouse[property] then
			if not propertySetterCache[property] then
				propertySetterCache[property] = function(self, value)
					RbxMouse[property] = value
				end
			end
			return propertySetterCache[property]
		elseif not thingsThatCanBeNil[index] then
			error(tostring(index).." is not a valid member of RbxMouse.")
		end
	end
})

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

local updateMode = RbxMouse.UPDATE_MANUAL do
	local updateConnection
	RbxMouse.GetUpdateMode = function()
		return updateMode
	end
	RbxMouse.SetUpdateMode = function(self, newUpdateMode)
		if newUpdateMode ~= updateMode and updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil	
		end
		updateMode = newUpdateMode
		if updateMode == RbxMouse.UPDATE_RENDER then
			updateConnection = game:GetService("RunService").RenderStepped:Connect(function()
				RbxMouse:UpdateTarget()
			end)
		end
	end
	RbxMouse:SetUpdateMode(updateMode)
end

do
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
		RbxMouse.Position = Vector2.new(position.X, position.Y)
		if updateMode == RbxMouse.UPDATE_MOVEMENT then
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
	
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local uit = input.UserInputType
		if uit == UIT_M1 or uit == UIT_M2 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			if not gameProcessed or not RbxMouse.IgnoreButtonInputWhenGameProcessed then
				processButtonDown(uit, gameProcessed)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		local uit = input.UserInputType
		if uit == UIT_M1 or uit == UIT_M2 or (RbxMouse.MapTouchToMouse and uit == UIT_T) then
			if not gameProcessed or not RbxMouse.IgnoreButtonInputWhenGameProcessed then
				processButtonUp(uit, gameProcessed)
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
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
	end)
	
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
	
	local deepCast = function(origin, direction, ignoreList, transparency, canCollide)
		-- TODO port RecursiveRaycast to this
		return workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, direction))
	end
	
	RbxMouse.RayUpdate = function(self)
		local screenRay = Camera:ScreenPointToRay(RbxMouse.Position.X, RbxMouse.Position.Y)
		RbxMouse.Ray = screenRay.Unit
		RbxMouse:FireRayUpdate(RbxMouse.Ray)
		return RbxMouse.Ray
	end
	
	RbxMouse.UpdateTarget = function(self, customList, customMethod, customDistance, ...)
		local ray = RbxMouse:RayUpdate()
		local raycastList = customList or RbxMouse.RaycastFilterList or {}
		local raycastMethod = customMethod or RbxMouse.RaycastMethod
		local raycastDistance = customDistance or RbxMouse.RaycastDistance
		
		local part, position, normal, material
		
		if raycastMethod == RbxMouse.RAYCAST_BASIC then
			part, position, normal, material = workspace:FindPartOnRay(
				Ray.new(ray.Origin, ray.Direction * raycastDistance),
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_IGNORELIST then
			part, position, normal, material = workspace:FindPartOnRayWithIgnoreList(
				Ray.new(ray.Origin, ray.Direction * raycastDistance),
				raycastList,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_FILTER_TRANSPARENT then
			part, position, normal, material = deepCast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastList,
				true,
				false,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_FILTER_COLLIDABLE then
			part, position, normal, material = deepCast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastList,
				false,
				true,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_FILTER_TRANSPARENT_COLLIDABLE then
			part, position, normal, material = deepCast(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastList,
				true,
				true,
				...
			)
		elseif raycastMethod == RbxMouse.RAYCAST_CUSTOM or type(raycastMethod) == "function" then
			local raycastFunction =
				((type(raycastMethod) == "function") and raycastMethod)
				or RbxMouse.CustomRaycastFunction
			part, position, normal, material = raycastMethod(
				ray.Origin,
				ray.Direction * raycastDistance,
				raycastList,
				...
			)
		end
		
		RbxMouse.Target = part
		RbxMouse.TargetMaterial = material
		
		local startPosition = position or ray.Origin + (ray.Direction * raycastDistance)
		local forwardVector = normal or ray.Direction
		local upVector = Vector3.new(0, 1, 0)
		local rightVector = forwardVector:Cross(upVector)
		upVector = rightVector:Cross(forwardVector)
		RbxMouse.CFrame = CFrame.fromMatrix(startPosition, rightVector, upVector)
		
		RbxMouse:FireTargetUpdate(part, RbxMouse.CFrame, material)
		return part, RbxMouse.CFrame, material
	end
end

return RbxMouse