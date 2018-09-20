local MouseIcon = {} do
    local UserInputService = game:GetService("UserInputService")
    local RenderStepped = game:GetService("RunService").RenderStepped
    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

    local currentMouseIcon = Mouse.Icon

    local hideConnection, hideCallback do
        hideCallback = function()
            UserInputService.MouseIconEnabled = false
        end
    end

    MouseIcon.set = function(id)
        local assetId =
            (typeof(id) == "number" and "rbxassetid://" ..id) or
            (typeof(id) == "string" and id) or
            (not id and "") or
            currentMouseIcon

        currentMouseIcon = assetId
        Mouse.Icon = currentMouseIcon
    end

    MouseIcon.get = function(id)
        return currentMouseIcon
    end

    MouseIcon.hide = function()
        if hideConnection then return end
        hideConnection = RenderStepped:Connect(hideCallback)
    end

    MouseIcon.show = function()
        if not hideConnection then return end
        hideConnection:Disconnect()
    end
end

return MouseIcon
