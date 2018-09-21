local methods = {} do
    local UserInputService = game:GetService("UserInputService")
    local RenderStepped = game:GetService("RunService").RenderStepped
    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

    local currentMouseIcon = Mouse.Icon

    methods.Hide = function()
		UserInputService.MouseIconEnabled = false
    end

    methods.Show = function()
		UserInputService.MouseIconEnabled = true
    end

    methods.Set = function(id)
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
