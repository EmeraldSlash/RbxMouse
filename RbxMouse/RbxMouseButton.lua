local CONFIG = require(script.Parent:WaitForChild("Configuration"))

local Signal = require(script.Parent:WaitForChild("Signal"))

local buttons = {}

local makeNewButton = function(buttonId)
    local buttonInputType = Enum.UserInputType["MouseButton" ..buttonId]

    local properties = {} do
        properties.ButtonId = buttonId
        properties.ButtonName =
            (buttonId == 1 and "Left") or
            (buttonId == 2 and "Right") or
            (buttonId == 3 and "Middle")

        properties.IsDown = false
        Input.bindActionBinary(buttonInputType, function(isBegin)
            properties.IsDown = isBegin
        end
    end

    local signals = {} do
        signals.Down = Signal.new()
        signals.Up = Signal.new()

        Input.bindActionBinary(buttonInputType, function(isBegin)
            if isBegin and not properties.IsDown then
                properties.IsDown = true
                signals.Down:Fire()
            elseif not isBegin and properties.IsDown then
                properties.IsDown = false
                signals.Up:Fire()
            end
        end)

        signal.Click = Signal.new() do
            local wentDownAt

            signal.Down.Event:Connect(function()
                wentDownAt = tick()
            end
            signal.Up.Event:Connect(function()
                local timeSpentDown = tick() - wentDownAt
                if timeSpentDown > CONFIG.ClickThreshold then return end
                signal.Click:Fire(timeSpentDown)
            end
        end
    end

    local methods = {} do
        methods.ForceDown = function()
            if properties.IsDown then return end
            properties.IsDown = true
            signals.Down:Fire()
        end
        methods.ForceUp = function()
            if not properties.IsDown then return end
            properties.IsDown = false
            signals.Up:Fire()
        end
    end

    local newButton = setmetatable(newButton, {
        __index = function(self, index)
            local property = properties[index]
            if property then return property end

            local signal = signals[index]
            if signal then return signal end

            local method = methods[index]
            if method then return method end

            error(tostring(index).. " is not a valid member of RbxMouseButton")
        end,
        __newindex = function() end
    })
end

local RbxMouseButtonContainer = {} do
    setmetatable(RbxMouseButtonContainer, {
        __index = function(self, index)
            local buttonId =
                ((index == 1 or index == "Left") and 1) or
                ((index == 2 or index == "Right") and 2) or
                ((index == 3 or index == "Middle") and 3)

            if not buttonId then error(tostring(index).. " is not a valid mouse button") end
            if not buttons[buttonId] then
                buttons[ButtonId] = makeNewButton(buttonId)
            end
            return buttons[ButtonId]
        end,
        __newindex = function() end
    })
end

return RbxMouseButtonContainer
