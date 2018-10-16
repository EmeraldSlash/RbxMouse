-- A custom mouse object that uses up-to-date APIs
-- Can be loaded using the Rostrap library manager
-- @author EmeraldSlash
-- @repository https://github.com/EmeraldSlash/RbxMouse

if not game:GetService("RunService"):IsClient() then
    error("RbxMouse can only run on the client")
end

local CONFIG = require(script:WaitForChild("Configuration"))
local UIT_MOUSE_MOVEMENT = Enum.UserInputType.MouseMovement

local Input = require(script:WaitForChild("Input"))

local children = {} do
    children.Button = require(script:WaitForChild("RbxMouseButton"))
    children.Icon = require(script:WaitForChild("RbxMouseIcon"))

    if CONFIG.TargetEnabled then
        children.TargetFilter = require(script:WaitForChild("RbxTargetFilter"))
    end
end

local properties = {} do
    local MouseRay = require(script:WaitForChild("MouseRay"))

    properties.Position = Vector2.new()
    properties.CFrame = CFrame.new()

	if not CONFIG.ConstantlyUpdatingProperties then
	    Input.bindActionChange(UIT_MOUSE_MOVEMENT, function(inputObject)
	        properties.Position = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
	        MouseRay.new(properties.Position, children.TargetFilter:Get())
	        properties.CFrame = MouseRay.getCFrame()
	    end)
	else
		Input.bindToFrame(function(UserInputService)
			local mousePosition = UserInputService:GetMouseLocation()
			properties.Position = mousePosition
	        MouseRay.new(mousePosition, children.TargetFilter:Get())
	        properties.CFrame = MouseRay.getCFrame()
		end)
	end

    if CONFIG.TargetEnabled then
        properties.Target = nil
		local updateTarget = function()
	    	properties.Target = MouseRay.getTarget()
	    end

		if not CONFIG.ConstantlyUpdatingProperties then
	        Input.bindActionChange(UIT_MOUSE_MOVEMENT, updateTarget)
		else
			Input.bindToFrame(updateTarget)
		end
    end
end

local signals = {} do
    signals.Move = Instance.new("BindableEvent")

    Input.bindActionChange(UIT_MOUSE_MOVEMENT, function()
        signals.Move:Fire(properties.Position)
    end)
end

local methods = {} do
    methods.Enable = function(self)
        Input.enable()
    end
    methods.Disable = function(self)
        Input.disable()
    end
end

local RbxMouse = {} do
    local getMember = function(self, index)
        local child = children[index]
        if child then return child end

        local property = properties[index]
        if property then return property end

        local signal = signals[index]
        if signal then return signal.Event end

        local method = methods[index]
        if method then return method end
    end

    setmetatable(RbxMouse, {
        __index = function(self, index)
            local member = getMember(self, index)
            if member then return member end
			if CONFIG.TargetEnabled and index == "Target" then return nil end

            error(tostring(index).. " is not a valid member of RbxMouse")
        end,
        __newindex = function() end
    })
end

return RbxMouse
