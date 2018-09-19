local CLICK_THRESHOLD = 0.5
local RAY_DISTANCE = 1000

local Custom = {}

local Services = {} do
    Services.RenderStepped = game:GetService("RunService").RenderStepped

    local Ray = {} do
        local Cache

        Ray.Create = function(Position, TargetFilter)
            local NewRay = Camera:ScreenPointToRay(Position.X, Position.Y) do
                NewRay = Ray(NewRay.Origin, NewRay.Direction * (Custom.RayDistance or RAY_DISTANCE))
            end

            Cache = {
                Ray = NewRay,
                Direction = NewRay.Unit.Direction,
                Result = {workspace:FindPartOnRayWithIgnoreList(NewRay, TargetFilter)}
            }
        end

        Ray.ResetCache = function()
            Cache = nil
        end
    end

    local UserInput = {} do
        local BeganConnection, EndedConnection, ChangedConnection
        local BeginAndEndFunctions = {}

        local Began, Ended, Changed do
            Began = function(Input)
                for _, Data in pairs(BeginAndEndFunctions) do
                    local Type, Value, Function = Data[1], Data[2], Data[3]
                    if Input[Type] == Value then
                        Function(true)
                    end
                end
            end

            Ended = function(Input)
                for _, Data in pairs(BeginAndEndFunctions) do
                    local Type, Value, Function = Data[1], Data[2], Data[3]
                    if Input[Type] == Value then
                        Function(false)
                    end
                end
            end

            Changed = function(Input)
                if Input.UserInputType == Enum.UserInput.MouseMovement then
                    local InputPosition = Input.Position
                    Services.MousePosition = Vector2.new(InputPosition.X, InputPosition.Y)
                    Ray.ResetCache()
                end
            end
        end

        UserInput.Service = game:GetService("UserInputService")

        UserInput.Connect = function()
            BeganConnection = UserInput.Service.InputBegan:Connect(Began)
            EndedConnection = UserInput.Service.InputEnded:Connect(Ended)
            ChangedConnection = UserInput.Service.InputChanged:Connect(Changed)
        end

        UserInput.Disconnect = function()
            BeganConnection:Disconnect()
            EndedConnection:Disconnect()
            ChangedConnection:Disconnect()
        end

        UserInput.BindFunctionToBeginAndEnd = function(Type, Value, Function)
            table.insert(BeginAndEndFunctions, {Type, Value, Function})
        end

        UserInput.Connect()
    end

    Services.BindButton = function(ButtonId, ButtonSignals)
        local InputType = Enum.UserInputType.["MouseButton" ..ButtonId]

        UserInput.BindFunctionToBeginAndEnd("UserInputType", InputType, function(Begin)
            if Begin then
                ButtonSignals.Down:Fire()
            else
                ButtonSignals.Up:Fire()
            end
        end)
    end

    Services.MousePosition = Vector2.new()
    Services.TargetFilter = {}

    Services.GetMouseCFrame = function()
        if not RayCache then MakeRay(Services.MousePosition, Services.TargetFilter) end
        return CFrame.new(RayCache.Result[2], RayCache.Direction)
    end

    Services.GetMouseTarget = function()
        if not RayCache then MakeRay(Services.MousePosition, Services.TargetFilter) end
        return RayCache.Result[1]
    end
end

local MouseButton = {} do
    local CreateButtonObject do
        local ButtonObject = {} do
            ButtonObject.__index = ButtonObject
        end

        local CreateButtonSignals = function(NewButtonObject)
            local ButtonSignals do
                ButtonSignals = {
                    Down = CreateSignal();
                    Up = CreateSignal();
                    Click = CreateSignal();
                }

                NewButtonObject.Down = ButtonSignals.Down.Event
                NewButtonObject.Up = ButtonSignals.Up.Event
                NewButtonObject.Click = ButtonSignals.Click.Event

                local LastDown do
                    NewButtonObject.Down:Connect(function()
                        NewButtonObject.IsDown = true
                        LastDown = tick()
                    end)

                    NewButtonObject.Up:Connect(function()
                        NewButtonObject.IsDown = false

                        local TimeSpentDown = tick() - LastDown
                        if TimeSpentDown <= CLICK_THRESHOLD then
                            -- Fire click event if time spent down was within the threshold
                            ButtonSignals.Click:Fire(TimeSpentDown)
                        end
                    end)
                end
            end
        end

        CreateButtonObject = function()
            local NewButtonObject = setmetatable({}, ButtonObject)
            local NewButtonSignals = CreateButtonSignals(NewButtonObject)

            NewButtonObject.IsDown = false

            return NewButtonObject, NewButtonSignals
        end
    end

    local SetupMouseButton = function(self, ButtonIdInput)
        local ButtonId =
            ((ButtonIdInput == 1 or ButtonIdInput == "Left") and 1) or
            ((ButtonIdInput == 2 or ButtonIdInput == "Right") and 2) or
            ((ButtonIdInput == 3 or ButtonIdInput == "Middle") and 3)

        if ButtonId then
            return MouseButton[ButtonId]
        elseif not ButtonId then
            error(tostring(Button) .. " is not a valid mouse button")
        end

        local Button, Signals = CreateButtonObject(Id)
        Services.BindButton(ButtonId, Signals)

        MouseButton[ButtonId] = Button
        return Button
    end

    setmetatable(MouseButton, {
        __index = SetupMouseButton
    })
end

local SetupMouseMethods do
    local Hide, Show do
        local Hider
        local HideFunction = function()
            Services.UserInput.Service.MouseIconEnabled = false
        end

        Hide = function()
            if Hider then return end
            Hider = Services.RenderStepped:Connect(HideFunction)
        end

        Show = function()
            if not Hider then return end
            Hider:Disconnect()
        end
    end

    local SetRayDistance = function(Distance)
        Custom.RayDistance = Distance
    end
    local SetClickThreshold = function(Threshold)
        Custom.ClickThreshold = Threshold
    end

    SetupMouseMethods = function(self)
        self.Pause = Services.UserInput.Disconnect
        self.Resume = Services.UserInput.Connect
        self.Hide = Hide
        self.Show = Show
        self.SetRayDistance = SetRayDistance
        self.SetClickThreshold = SetClickThreshold
    end
end

local SetupMouseProperty do
    local PropertySignals = {
        Move = CreateSignal()
    }

    SetupMouseProperty = function(self, PropertyInput)
        local Signal = PropertySignals[PropertyInput]
        if Signal then
            self[PropertyInput] = Signal.Event
            return Signal.Event
        end

        if PropertyInput == "Position" then
            return Services.MousePosition
        elseif PropertyInput == "CFrame" then
            return Services.GetMouseCFrame()
        elseif PropertyInput == "Target" then
            return Services.GetMouseTarget()
        end

        SetupMouseMethod(self, PropertyInput)
    end
end

local Mouse = {} do
    Mouse.Button = MouseButton

    SetupMouseMethods(Mouse)

    setmetatable(Mouse, {
        __index = SetupMouseProperty
    })
end

return Mouse
