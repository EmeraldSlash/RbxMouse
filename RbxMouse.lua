local DEFAULT_CLICK_THRESHOLD = 0.5
local DEFAULT_RAY_DISTANCE = 1000

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	warn("[Mouse] Mouse library can only be used on the client.")
	return {}
end

local LocalPlayer = Players.LocalPlayer

local Vector2 = Vector2.new
local CFrame = CFrame.new
local Ray = Ray.new
local New = Instance.new
local RenderStepped = RunService.RenderStepped

local CustomClickThreshold = nil
local CustomRayDistance = nil

local EventStorage = {}

local EventObject = {} do
	EventObject.__index = EventObject
	
	local Bindables = {}
	
	function EventObject.new(Id)
		local NewEventObject = {}
		setmetatable(NewEventObject, EventObject)		
		
		NewEventObject.Id = Id
		
		local Bindable = New("BindableEvent")
		Bindables[Id] = Bindable
		
		return NewEventObject
	end
	
	function EventObject:Connect(...)
		return Bindables[self.Id].Event:Connect(...)
	end
	function EventObject:Wait(...)
		return Bindables[self.Id].Event:Wait(...)
	end
	function EventObject:Fire(...)
		return Bindables[self.Id]:Fire(...)
	end
end

local function CreateEvent(Id)
	local Event = EventStorage[Id]
	
	if not Event then
		Event = EventObject.new(Id)
		EventStorage[Id] = Event
	end
	
	return Event
end

local TargetFilter = {} do
	local FilterTable = {}
	
	function TargetFilter:Set(Object)
		if type(Object) == "table" then
			FilterTable = Object
		else
			FilterTable = {Object}
		end
	end
	
	function TargetFilter:Add(Object)
		if type(Object) ~= "table" then
			table.insert(FilterTable, Object)
		end
	end
	
	function TargetFilter:Remove(Object)
		local ToRemove = {}
		for Index, CurrentObject in pairs(FilterTable) do
			if CurrentObject == Object then
				table.insert(ToRemove, Index)
			end
		end
		for Position = 0, #ToRemove-1 do
			table.remove(FilterTable, ToRemove[Position] - Position)
		end
	end

	function TargetFilter:Get()
		return FilterTable
	end
end

local MouseIcon = {} do
	local MouseObject = LocalPlayer:GetMouse()
	
	function MouseIcon:Set(Icon)
		if type(Icon) == "number" then
			Icon = "rbxassetid://" .. Icon
		elseif Icon == nil then
			Icon = ""
		end
		MouseObject.Icon = Icon
	end
	
	function MouseIcon:Get()
		return MouseObject.Icon
	end
end

local World = {} do
	local Camera = workspace.CurrentCamera
	local CurrentRay, CurrentRayData
	
	local function MakeCurrentRay(Position)
		local NewRay = Camera:ScreenPointToRay(Position.X, Position.Y)
		CurrentRay = Ray(NewRay.Origin, NewRay.Direction * (CustomRayDistance or DEFAULT_RAY_DISTANCE))
		CurrentRayData = {workspace:FindPartOnRayWithIgnoreList(CurrentRay, TargetFilter:Get())}
	end
	
	function World:GetCFrame(Position)
		if not CurrentRayData then
			MakeCurrentRay(Position)
		end
		
		return CurrentRayData[2] or CFrame()
	end
	
	function World:GetTarget(Position)
		if not CurrentRayData then
			MakeCurrentRay(Position)
		end
		
		return CurrentRayData[1] or nil
	end
	
	function World:Reset()
		CurrentRay = nil
		CurrentRayData = nil
	end
end

local ButtonNumber = {} do
	local Cache = {}	
	
	function ButtonNumber:Get(InputType)
		if Cache[InputType] then
			return Cache[InputType]
		end		
		
		local Match = string.match(tostring(InputType), "MouseButton%d")
		Match = tonumber(Match)
		
		if Match ~= nil then
			Cache[InputType] = Match
		end		
		return Match
	end
end

local MouseHider = {} do
	local function Function()
		UserInputService.MouseIconEnabled = false
	end
	local Connection	
	
	function MouseHider:Resume()
		Connection = RenderStepped:Connect(Function)
	end
	function MouseHider:Pause()
		Connection:Disconnect()
	end
end

local UserInput = {} do
	local MouseInput = {} do
		local ClickStart = {}		
		
		function MouseInput:Down(Number)
			local Event = EventStorage["Button" ..Number.. "Down"]
			if Event then
				Event:Fire()
			end
			
			ClickStart[Number] = tick()
		end
		
		function MouseInput:Up(Number)
			local Event = EventStorage["Button" ..Number.. "Up"]
			if Event then
				Event:Fire()
			end
			
			if (tick() - ClickStart[Number]) <= (CustomClickThreshold or DEFAULT_CLICK_THRESHOLD) then
				local EventClick = EventStorage["Button" ..Number.. "Click"]
				if EventClick then
					EventClick:Fire()
				end
			end
			ClickStart[Number] = nil
		end
		
		function MouseInput:Movement(Input)
			local Event = EventStorage["Move"]
			if Event then
				local NewPosition = Vector2(Input.Position.X, Input.Position.Y)
				print("Sent", NewPosition)
				Event:Fire(NewPosition)
			end
		end
	end	
	
	local function InputBeginFunction(Input)
		local Type = Input.UserInputType
		local Number = ButtonNumber:Get(Type)
		if Type == Enum.UserInputType.MouseMovement then
			MouseInput:Movement(Input)
		elseif Number ~= nil then
			MouseInput:Down(Number)
		end
	end
	
	local function InputEndFunction(Input)
		local Type = Input.UserInputType
		local Number = ButtonNumber:Get(Type)
		if Type == Enum.UserInputType.MouseMovement then
			MouseInput:Movement(Input)
		elseif Number ~= nil then
			MouseInput:Up(Number)
		end
	end
	
	local function InputChangeFunction(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			MouseInput:Movement(Input)
		end
	end
	
	local BeginConnection, EndedConnection, ChangedConnection
	
	function UserInput:Resume()
		BeginConnection = UserInputService.InputBegan:Connect(InputBeginFunction)
		EndedConnection = UserInputService.InputEnded:Connect(InputEndFunction)
		ChangedConnection = UserInputService.InputChanged:Connect(InputChangeFunction)
	end	
	function UserInput:Pause()
		BeginConnection:Disconnect()
		EndedConnection:Disconnect()
		ChangedConnection:Disconnect()
	end
	
	UserInput:Resume()
end

local Mouse = {} do
	local WatchingCFrame, WatchingTarget = false, false
	
	Mouse.TargetFilter = TargetFilter
	Mouse.Icon = MouseIcon
	
	function Mouse:Hide()
		MouseHider:Resume()
	end
	function Mouse:Show()
		MouseHider:Pause()
	end
	
	function Mouse:Pause()
		UserInput:Pause()
	end
	function Mouse:Resume()
		UserInput:Resume()
	end
	
	function Mouse:SetClickThreshold(Time)
		CustomClickThreshold = (not Time and nil) or Time
	end
	function Mouse:SetRayDistance(Distance)
		CustomRayDistance = (not Distance and nil) or Distance
	end
		
	local MoveEvent = CreateEvent("Move")
	Mouse.Move = MoveEvent
	Mouse.Position = Vector2()
	
	MoveEvent:Connect(function(NewPosition)
		Mouse.Position = NewPosition
		
		if WatchingCFrame then
			Mouse.CFrame = World:GetCFrame(NewPosition)
		end
		if WatchingTarget then
			Mouse.Target = World:GetTarget(NewPosition)
		end
		World:Reset()
	end)
	
	local HandleUndefinedRequest do		
		local function HandlePropertyRequest(self, String)
			if String == "CFrame" then
				WatchingCFrame = true
				
				local Value = World:GetCFrame(self.Position)
				self.CFrame = Value
				
				return Value			
			elseif String == "Target" then
				WatchingTarget = true
				
				local Value = World:GetTarget(self.Position)
				self.Target = Value
					
				return Value or false
			elseif String == "Position" then
				return Vector2()
			end
		end
		
		local function HandleEventRequest(self, String)
			local NewEvent
			local Number, Type = string.match(String, "Button(%d+)(.+)")
			
			if (not Number or Number == "") or (not Type or Type == "") then
				warn("[Mouse] " ..String.. " is not a valid mouse event.")
				return
			end
				
			NewEvent = CreateEvent(String)
			if NewEvent then
				self[String] = NewEvent
			end
			
			return NewEvent	
		end
		
		HandleUndefinedRequest = function(...)
			local Result = HandlePropertyRequest(...)
			
			if Result == nil then
				Result = HandleEventRequest(...)
			else
				Result = nil
			end
			
			return Result
		end
	end
	
	setmetatable(Mouse, {
		__index = HandleUndefinedRequest
	})
end

return Mouse
