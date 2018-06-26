local DEFAULT_CLICK_TIMEOUT = 0.5
local RAY_DISTANCE = 1000

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
local RenderStepped = RunService.RenderStepped

local CustomClickTimeout = nil
local CustomRayDistance = nil

local TargetFilter = {} do
	local FilterTable = {}
	
	function TargetFilter:Set(Object)
		if type(Object) == "table" then
			FilterTable = Object
		else
			FilterTable = {Object}
		end
	end
	
	function TargetFilter:AddObject(Object)
		if type(Object) ~= "table" then
			table.insert(FilterTable, Object)
		end
	end
	
	function TargetFilter:RemoveObject(Object)
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

local World = {} do
	local Camera = workspace.CurrentCamera
	local CurrentRay, CurrentRayData
	
	local function MakeCurrentRay(Position)
		CurrentRay = Camera:ScreenPointToRay(Position.X, Position.Y, (CustomRayDistance or RAY_DISTANCE))
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

local MouseStorage = {}

local UserInput = {} do
	local MouseInput = {} do
		local ClickStart = {}		
		
		function MouseInput:Down(Number)
			local Event = MouseStorage["Button" ..Number.. "Down"]
			if Event then
				Event:Fire()
			end
			
			ClickStart[Number] = tick()
		end
		
		function MouseInput:Up(Number)
			local Event = MouseStorage["Button" ..Number.. "Up"]
			if Event then
				Event:Fire()
			end
			
			if (tick() - ClickStart[Number]) <= (CustomClickTimeout or DEFAULT_CLICK_TIMEOUT) then
				local EventClick = MouseStorage["Button" ..Number.. "Click"]
				if EventClick then
					EventClick:Fire()
				end
			end
			ClickStart[Number] = nil
		end
		
		function MouseInput:Movement(Input)
			local Event = MouseStorage["Move"]
			if Event then
				local NewPosition = Vector2(Input.Position.X, Input.Position.Z)
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
	local MouseObject = LocalPlayer:GetMouse()
	local WatchingCFrame, WatchingTarget = false, false
	
	local MouseEventCreator = {} do	
		local MouseEvent = {} do
			MouseEvent.__index = MouseEvent
			
			function MouseEvent.new()
				local NewMouseEvent = {}
				NewMouseEvent.Bindable = Instance.new("BindableEvent")
				
				setmetatable(NewMouseEvent, MouseEvent)
				return NewMouseEvent
			end			
			
			function MouseEvent:Connect(Function)
				return self.Bindable.Event:Connect(Function)
				--return setmetatable({}, MouseEventConnection)
			end
			
			function MouseEvent:Fire()
				return self.Bindable:Fire()
			end
		end
		
		function MouseEventCreator:CreateEvent(Id)
			local Event = MouseStorage[Id]
			
			if Event == nil then
				Event = MouseEvent.new(Id)
				MouseStorage[Id] = Event
			end
			
			return Event
		end
	end	
	
	--[[for Button = 1, 3 do
		local DownId = "Button" ..Button.. "Down"
		Mouse[DownId] = MouseEventCreator:CreateEvent(DownId)
		local UpId = "Button" ..Button.. "Up"
		Mouse[UpId] = MouseEventCreator:CreateEvent(UpId)
		local ClickId = "Button" ..Button.. "Click"
		Mouse[ClickId] = MouseEventCreator:CreateEvent(ClickId)
	end]]
	
	function Mouse:SetTargetFilter(Function)
		TargetFilter = Function
	end
	function Mouse:SetIcon(Icon)
		if type(Icon) == "number" then
			Icon = "rbxassetid://" .. Icon
		elseif Icon == nil then
			Icon = ""
		end
		MouseObject.Icon = Icon
	end
	
	function Mouse:SetClickTimeout(Time)
		CustomClickTimeout = (not Time and nil) or Time
	end
	
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
		
	local MoveEvent = MouseEventCreator:CreateEvent("Move")
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
	
	setmetatable(Mouse, {
		__index = function(self, String)
			if String == "CFrame" then
				if WatchingCFrame then return end
				WatchingCFrame = true
				
				local Value = World:GetCFrame(Mouse.Position)
				Mouse.CFrame = Value
				
				return Value			
			elseif String == "Target" then
				if WatchingTarget then return end
				WatchingTarget = true
				
				local Value = World:GetTarget(Mouse.Position)
				Mouse.Target = Value
				
				return Value
			elseif String == "Position" then
				return Vector2()
			end			
			
			local NewEvent
			
			if String == "Move" then
				NewEvent = MouseEventCreator:CreateEvent(String)	
			else
				local Number, Type = string.match(String, "Button(%d+)(.+)")
			
				if (not Number or Number == "") or (not Type or Type == "") then
					warn("[Mouse] " ..String.. " is not a valid mouse event.")
					return
				end
				
				NewEvent = MouseEventCreator:CreateEvent(String)	
			end
			
			if NewEvent then
				Mouse[String] = NewEvent
			end
			
			return NewEvent	
		end
	})
end

return Mouse
