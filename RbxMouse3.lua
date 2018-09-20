if not game:GetService("RunService"):IsClient() then
    error("RbxMouse can only run on the client")
end

local CONFIG = require(script:WaitForChild("Configuration"))
local UIT_MOUSE_MOVEMENT = Enum.UserInputType.MouseMovement

local Input = require(script:WaitForChild("Input"))

local children = {} do
    children.Button = require(script:WaitForChild("Button"))

    if CONFIG.TargetEnabled then
        children.TargetFilter = require(script:WaitForChild("TargetFilter"))
    end
end

local properties = {} do
    local MouseRay = require(script:WaitForChild("MouseRay"))

    properties.Position = Vector2.new()
    properties.CFrame = CFrame.new()

    Input.bindActionChange(UIT_MOUSE_MOVEMENT, function(inputObject)
        properties.Position = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
        MouseRay.new(properties.Position, children.TargetFilter:Get())
        properties.CFrame = MouseRay.getCFrame()
    end)

    if CONFIG.TargetEnabled then
        properties.Target = nil
        Input.bindAction(UIT_MOUSE_MOVEMENT, function()
            properties.Target = MouseRay.getTarget()
        end)
    end
end

local signals = {} do
    local Signal = require(script:WaitForChild("Signal"))

    signals.Move = Signal.new()
    Input.bindAction(UIT_MOUSE_MOVEMENT, function()
        signals.Move:Fire(properties.Position)
    end)
end

local methods = {} do
    methods.Hide = function(self)
        MouseIcon.hide()
    end
    methods.Show = function(self)
        MouseIcon.show()
    end

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

    setmetatable(Mouse, {
        __index = function(self, index)
            local member = getMember(self, index)
            if member then return member end

            error(tostring(index).. " is not a valid member of RbxMouse")
        end
    })
end

return RbxMouse
