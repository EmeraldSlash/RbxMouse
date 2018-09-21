local CONFIG = require(script.Parent:WaitForChild("Configuration"))

local Input = require(script.Parent:WaitForChild("Input"))

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
    end

    local signals = {} do
        signals.Down = Instance.new("BindableEvent")
        signals.Up = Instance.new("BindableEvent")

        Input.bindActionBinary(buttonInputType, function(isBegin)
            if isBegin and not properties.IsDown then
                properties.IsDown = true
                signals.Down:Fire()
            elseif not isBegin and properties.IsDown then
                properties.IsDown = false
                signals.Up:Fire()
            end
        end)

        signals.Click = Instance.new("BindableEvent") do
            local wentDownAt

            signals.Down.Event:Connect(function()
                wentDownAt = tick()
            end)
            signals.Up.Event:Connect(function()
                local timeSpentDown = tick() - wentDownAt
                if timeSpentDown > CONFIG.ClickThreshold then return end
                signals.Click:Fire(timeSpentDown)
            end)
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

    local newButton = {} do
		setmetatable(newButton, {
	        __index = function(self, index)
	            local property = properties[index]
	            if property then return property end

	            local signal = signals[index]
	            if signal then return signal.Event end

	            local method = methods[index]
	            if method then return method end

	            error(tostring(index).. " is not a valid member of RbxMouseButton")
	        end,
	        __newindex = function() end
		})
	end

	return newButton
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
                buttons[buttonId] = makeNewButton(buttonId)
            end
            return buttons[buttonId]
        end,
        __newindex = function() end
    })
end

return RbxMouseButtonContainer
