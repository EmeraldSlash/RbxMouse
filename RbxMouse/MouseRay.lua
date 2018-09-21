local CONFIG = require(script.Parent:WaitForChild("Configuration"))

local MouseRay = {} do
    local Ray = Ray.new
    local CFrame = CFrame.new
    local Camera = workspace.CurrentCamera

    local cache = {nil, CFrame()}

    MouseRay.new = function(position, targetFilter)
        local newRay = Camera:ScreenPointToRay(position.X, position.Y) do
            newRay = Ray(newRay.Origin, newRay.Direction * CONFIG.RaycastDistance)
        end

        cache = {workspace:FindPartOnRayWithIgnoreList(newRay, targetFilter)}
        cache[3] = newRay.Unit.Direction
    end

    MouseRay.getCFrame = function()
        return CFrame(cache[2], cache[3])
    end

    MouseRay.getTarget = function()
        return cache[1]
    end
end

return MouseRay
