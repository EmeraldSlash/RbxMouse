local methods = {} do
    local UserInputService = game:GetService("UserInputService")
    local RenderStepped = game:GetService("RunService").RenderStepped
    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

    local currentMouseIcon = Mouse.Icon
    local hideConnection, hideCallback do
        hideCallback = function()
            UserInputService.MouseIconEnabled = false
        end
    end

    methods.Hide = function()
        if hideConnection then return end
        hideConnection = RenderStepped:Connect(hideCallback)
    end

    methods.Show = function()
        if not hideConnection then return end
        hideConnection:Disconnect()
    end

    methods.Set = function()
        local assetId =
            (typeof(id) == "number" and "rbxassetid://" ..id) or
            (typeof(id) == "string" and id) or
            (not id and "") or
            Mouse.Icon

        Mouse.Icon = assetId
    end

    methods.Get = function()
        return Mouse.Icon
    end
end

local RbxMouseIcon = {} do
    setmetatable(RbxMouseIcon, {
        __index = function(self, index)
            local method = methods[index]
            if method then return method end

            error(tostring(index).. " is not a valid member of RbxMouseIcon")
        end,
        __newindex = function() end
    })
end

return RbxMouseIcon
