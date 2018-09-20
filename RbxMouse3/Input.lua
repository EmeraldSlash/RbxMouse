local CONFIG = require(script.Parent:WaitForChild("Configuration"))
local UIT_TOUCH = Enum.UserInputType.Touch
local UIT_BUTTON1 = Enum.UserInputType.MouseButton1

local boundActions = {}
local boundBinaryActions = {}
local boundChangeActions = {}

local connectionBegin, connectionEnd, connectionChanged
local callbackBegan, callbackEnded, callbackChanged do
    callbackBegan = function(inputObject)
        local input = inputObject.UserInputType
        if (CONFIG.DetectTouchAsButton1 and input == UIT_TOUCH) then
            inputValue = UIT_BUTTON1
        then

        local inputCallbacks = boundActions[input]
        if inputCallbacks then
            for index = 1, #inputCallbacks do
                inputCallbacks[index]()
            end
        end

        local inputBinaryCallbacks = boundBinaryActions[input]
        if inputBinaryCallbacks then
            for index = 1, #inputCallbacks do
                inputCallbacks[index](true)
            end
        end
    end

    callbackEnded = function(inputObject)
        local input = inputObject.UserInputType
        if (CONFIG.DetectTouchAsButton1 and input == UIT_TOUCH) then
            input = UIT_BUTTON1
        then

        local inputBinaryCallbacks = boundBinaryActions[input]
        if inputBinaryCallbacks then
            for index = 1, #inputCallbacks do
                inputCallbacks[index](false)
            end
        end
    end

    callbackChanged = function(inputObject)
        local input = inputObject.UserInputType
        local inputCallbacks = boundChangedActions[input]

        if inputCallbacks then
            for index = 1, #inputCallbacks do
                inputCallbacks[index](inputObject)
            end
        end
    end
end

local Input = {} do
    local UserInputService = game:GetService("")

    Input.bindAction = function(action, callback)
        if not boundActions[action] then boundActions[action] = {} end
        table.insert(boundActions[action], callback)
    end

    Input.bindActionBinary = function(action, callback)
        if not boundBinaryActions[action] then boundBinaryActions[action] = {} end
        table.insert(boundBinaryActions[action], callback)
    end

    Input.bindActionChange = function(action, callback)
        if not boundChangeActions[action] then boundChangeActions[action] = {} end
        table.insert(boundChangeActions[action], callback)
    end

    Input.disable = function()
        connectionBegan:Disconnect()
        connectionEnded:Disconnect()
        connectionChanged:Disconnect()
    end

    Input.enable = function()
        connectionBegan = UserInputService.InputBegan:Connect(callbackBegan)
        connectionEnded = UserInputService.InputEnded:Connect(callbackEnded)
        connectionChanged = UserInputService.InputChanged:Connect(callbackChanged)
    end

    Input.enable()
end

return Input
