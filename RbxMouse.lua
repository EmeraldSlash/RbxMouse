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

local MouseHider do
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

local UserInput do
	local MouseInput = {} do
		function MouseInput:Down(Input, Button)
			
		end
		
		function MouseInput:Up(Input, Button)
			
		end
		
		function MouseInput:Movement(Input)
			
		end
	end	
	
	local function InputBeginFunction(Input)
		local Type = Input.UserInputType
		if Type == Enum.UserInputType.MouseMovement then
			MouseInput:Movement(Input)
		elseif ButtonNumber:Get(Type) ~= nil then
			MouseInput:Down(Input, ButtonNumber:Get(Type))
		end
	end
	
	local function InputEndFunction(Input)
		local Type = Input.UserInputType
		if Type == Enum.UserInputType.MouseMovement then
			MouseInput:Movement(Input)
		elseif ButtonNumber:Get(Type) ~= nil then
			MouseInput:Up(Input, ButtonNumber:Get(Type))
		end
	end
	
	local function InputChangeFunction(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			MouseInput:Movement(Input)
		end
	end
	
	local BeginConnection, EndedConnection, ChangedConnection
	
	UserInputService.InputBegan:Connect()
	
	UserInputService.InputEnded:Connect()
	
	UserInputService.InputChanged:Connect()
	
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
	
	local MouseEventCreator = {} do	
		local MouseEvent = {} do
			MouseEvent.__index = MouseEvent
			
			function MouseEvent.new()
				local NewMouseEvent = {}
				NewMouseEvent.Bindable = Instance.new("BindableEvent")
				
				setmetatable(MouseEvent, NewMouseEvent)
			end			
			
			function MouseEvent:Connect(Function)
				
			end
			
			function MouseEvent:Disconnect(Function)
				
			end
			
			function MouseEvent:Fire()
				
			end
		end
		
		function MouseEventCreator:CreateDownEvent(Id)
			local Event = MouseStorage[Id]
			
			if Event == nil then
				Event = MouseEvent.new()
				MouseStorage[Id] = Event
			end
			
			return Event
		end
	end	
	
	for Button = 1, 3 do
		local DownId = "Button" ..Button.. "Down"
		Mouse[DownId] = MouseEventCreator:CreateDownEvent(DownId)
		local UpId = "Button" ..Button.. "Up"
		Mouse[UpId] = MouseEventCreator:CreateUpEvent(UpId)
		local ClickId = "Button" ..Button.. "Click"
		Mouse[ClickId] = MouseEventCreator:CreateClickEvent(ClickId)
	end
	
	Mouse.Position = Vector2()
	Mouse.CFrame = CFrame()
	Mouse.Target = nil
	
	function Mouse:SetTargetFilter(Function)
		self.TargetFilter = Function
	end
	function Mouse:SetIcon(Icon)
		MouseObject.Icon = Icon or ""
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
end

return Mouse
