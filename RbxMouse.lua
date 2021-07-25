--[[

RbxMouse v4.0
https://github.com/EmeraldSlash/RbxMouse

See repository for detailed documentation :)

-- Properties

bool RbxMouse.Button1				[readonly]
bool RbxMouse.Button2				[readonly]
bool RbxMouse.Button3				[readonly]

KeyCode RbxMouse.Button1KeyCode
KeyCode RbxMouse.Button2KeyCode
KeyCode RbxMouse.Button3KeyCode

Vector2 RbxMouse.Position			[readonly]
Vector2 RbxMouse.InsetPosition	[readonly]

-- Signals

RbxMouse.Button1Pressed(bool gameProcessed, InputObject input)
RbxMouse.Button2Pressed(bool gameProcessed, InputObject input)
RbxMouse.Button3Pressed(bool gameProcessed, InputObject input)

RbxMouse.Button1Released(float duration, bool gameProcessed, InputObject input)
RbxMouse.Button2Released(float duration, bool gameProcessed, InputObject input)
RbxMouse.Button3Released(float duration, bool gameProcessed, InputObject input)

RbxMouse.Scrolled(int direction, bool gameProcessed, InputObject input)
RbxMouse.ScrolledUp(int direction, bool gameProcessed, InputObject input)
RbxMouse.ScrolledDown(int direction, bool gameProcessed, InputObject input)

RbxMouse.Moved(Vector2 delta, bool gameProcessed, InputObject input)

-- Methods

bool RbxMouse:GetVisible()
void RbxMouse:SetVisible(bool visible)

float RbxMouse:GetSensitivity()
void RbxMouse:SetSensitivity(float sensitivity)

bool RbxMouse:GetEnabled()
Vector2 RbxMouse:GetDelta()
array<InputObject> RbxMouse:GetButtonsPressed()
bool RbxMouse:IsButtonPressed(UserInputType mouseButton)

string RbxMouse:GetIcon()
void RbxMouse:SetIcon(string asset)
void RbxMouse:PushIcon(string asset)
void RbxMouse:PopIcon(optional string asset)
void RbxMouse:ClearAllIcons()
void RbxMouse:ClearIconStack()

MouseBehavior RbxMouse:GetBehavior()
void RbxMouse:SetBehavior(MouseBehavior behavior)
void RbxMouse:SetBehaviorEveryFrame(MouseBehavior behavior, optional int renderStepPriority)
void RbxMouse:StopSettingBehaviorEveryFrame()

void RbxMouse:Fire<Signal>(<signalParameters>)

Ray RbxMouse:GetRay(optional table rayOptions)
	rayOptions: {MaxDistance = number, Position = Vector2/UDim2, ApplyInset = number}

<void|RaycastResult> RbxMouse:GetTarget(
   optional RaycastParams params,
   optional function filter,
   optional <Ray|table> ray,
   optional bool canMutateParams
)
	filter: bool filter (RaycastResult result, RaycastParams params, Vector3 origin, Vector3 direction)

Vector2 RbxMouse:AbsoluteToInset(Vector2 absolutePosition)
Vector2 RbxMouse:InsetToAbsolute(Vector2 insetPosition)

-- Filter function presets

bool RbxMouse.FILTER_VISIBLE(RaycastResult result)
bool RbxMouse.FILTER_CANCOLLIDE(RaycastResult result)
bool RbxMouse.FILTER_VISIBLE_AND_CANCOLLIDE(RaycastResult result)
bool RbxMouse.FILTER_VISIBLE_OR_CANCOLLIDE(RaycastResult result)

--]]

local RbxMouse = {}

do
   local function addSignal(name)
      local bindable = Instance.new("BindableEvent")
      RbxMouse[name] = bindable.Event
      RbxMouse["Fire"..name] = function(_, ...)
         bindable:Fire(...)
      end
   end
   addSignal("Button1Pressed")
   addSignal("Button1Released")
   addSignal("Button2Pressed")
   addSignal("Button2Released")
   addSignal("Button3Pressed")
   addSignal("Button3Released")
   addSignal("Scrolled")
   addSignal("ScrolledUp")
   addSignal("ScrolledDown")
   addSignal("Moved")
end

do
   local guiService = game:GetService("GuiService")

   function RbxMouse:AbsoluteToInset(position)
      return position - guiService:GetGuiInset()
   end

   function RbxMouse:InsetToAbsolute(position)
      return position + guiService:GetGuiInset()
   end
end

local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local deltaSensitivity = 1
local currentFrameId = 0
local lastRecordedDelta = Vector2.new()
local lastRecordedDeltaId = currentFrameId

do
   local UIT = Enum.UserInputType
   local UIT_MM = UIT.MouseMovement
   local UIT_M1 = UIT.MouseButton1
   local UIT_M2 = UIT.MouseButton2
   local UIT_M3 = UIT.MouseButton3
   local UIT_MW = UIT.MouseWheel
   local UIT_T = UIT.Touch

   RbxMouse.Button1KeyCode = Enum.KeyCode.ButtonA
   RbxMouse.Button2KeyCode = nil
   RbxMouse.Button3KeyCode = nil

   RbxMouse.Button1 = false;
   RbxMouse.Button2 = false;
   RbxMouse.Button3 = false;

   local button1DownAt = 0
   local button2DownAt = 0
   local button3DownAt = 0

   userInputService.InputBegan:Connect(function(input, gameProcessed)
      if (input.UserInputType == UIT_M1) or
         (input.UserInputType == UIT_T) or
         (input.KeyCode == RbxMouse.Button1KeyCode)
      then
         button1DownAt = os.clock()
         RbxMouse.Button1 = true
         RbxMouse:FireButton1Pressed(gameProcessed, input)
      elseif (input.UserInputType == UIT_M2) or
         (input.KeyCode == RbxMouse.Button2KeyCode)
      then
         button2DownAt = os.clock()
         RbxMouse.Button2 = true
         RbxMouse:FireButton2Pressed(gameProcessed, input)
      elseif (input.UserInputType == UIT_M3) or
         (input.KeyCode == RbxMouse.Button3KeyCode)
      then
         button3DownAt = os.clock()
         RbxMouse.Button3 = true
         RbxMouse:FireButton3Pressed(gameProcessed, input)
      end
   end)

   userInputService.InputEnded:Connect(function(input, gameProcessed)
      if (input.UserInputType == UIT_M1) or
         (input.UserInputType == UIT_T) or
         (input.KeyCode == RbxMouse.Button1KeyCode)
      then
         RbxMouse.Button1 = false
         RbxMouse:FireButton1Released(os.clock()-button1DownAt, gameProcessed, input)
      elseif (input.UserInputType == UIT_M2) or
         (input.KeyCode == RbxMouse.Button2KeyCode)
      then
         RbxMouse.Button2 = false
         RbxMouse:FireButton2Released(os.clock()-button2DownAt, gameProcessed, input)
      elseif (input.UserInputType == UIT_M3) or
         (input.KeyCode == RbxMouse.Button3KeyCode)
      then
         RbxMouse.Button3 = false
         RbxMouse:FireButton3Released(os.clock()-button3DownAt, gameProcessed, input)
      end
   end)

   RbxMouse.Position = userInputService:GetMouseLocation()
   RbxMouse.InsetPosition = RbxMouse:AbsoluteToInset(RbxMouse.Position)

   local lastPosition = RbxMouse.Position
   userInputService.InputChanged:Connect(function(input, gameProcessed)
      if (input.UserInputType == UIT_MM) or (input.UserInputType == UIT_T) then
         RbxMouse.InsetPosition = Vector2.new(input.Position.X, input.Position.Y)
         RbxMouse.Position = RbxMouse:InsetToAbsolute(RbxMouse.InsetPosition)

         local delta = Vector2.new(input.Delta.X, input.Delta.Y)
         if delta.Magnitude == 0 then
            delta = (RbxMouse.Position - lastPosition) * userInputService.MouseDeltaSensitivity
         end
         delta *= deltaSensitivity
         lastPosition = RbxMouse.Position
         lastRecordedDelta = delta
         lastRecordedDeltaId = currentFrameId

         RbxMouse:FireMoved(delta, gameProcessed, input)
      elseif (input.UserInputType == UIT_MW) then
         RbxMouse:FireScrolled(input.Position.Z, gameProcessed, input)
         if (input.Position.Z > 0) then
            RbxMouse:FireScrolledUp(input.Position.Z, gameProcessed, input)
         elseif (input.Position.Z < 0) then
            RbxMouse:FireScrolledDown(input.Position.Z, gameProcessed, input)
         end
      end
   end)

   runService:BindToRenderStep("RbxMouseFrame", Enum.RenderPriority.First.Value, function()
      currentFrameId += 1
   end)
end

do
   function RbxMouse:GetVisible()
      return userInputService.MouseIconEnabled
   end
   function RbxMouse:SetVisible(visible)
      userInputService.MouseIconEnabled = visible
   end

   function RbxMouse:GetBehavior()
      return userInputService.MouseBehavior
   end
   function RbxMouse:SetBehavior(behavior)
      userInputService.MouseBehavior = behavior
   end
   function RbxMouse:SetBehaviorEveryFrame(behavior, priority)
      behavior = behavior or userInputService.MouseBehavior
      priority = priority or Enum.RenderPriority.Camera.Value - 1
      runService:BindToRenderStep("RbxMouseBehavior", priority, function()
         userInputService.MouseBehavior = behavior
      end)
   end
   function RbxMouse:StopSettingBehaviorEveryFrame()
      runService:UnbindFromRenderStep("RbxMouseBehavior")
   end

   function RbxMouse:GetSensitivity()
      return deltaSensitivity
   end
   function RbxMouse:SetSensitivity(sensitivity)
      deltaSensitivity = sensitivity
   end

   function RbxMouse:GetEnabled()
      return userInputService.MouseEnabled
   end
   function RbxMouse:GetDelta()
      local delta = userInputService:GetMouseDelta()
      if delta.Magnitude == 0 then
         if lastRecordedDeltaId == currentFrameId-1 then
            delta = lastRecordedDelta
         end
      else
         delta *= deltaSensitivity
      end
      return delta
   end
   function RbxMouse:GetButtonsPressed()
      return userInputService:GetMouseButtonsPressed()
   end
   function RbxMouse:IsButtonPressed(mouseButton)
      return userInputService:IsMouseButtonPressed(mouseButton)
   end
end

do
   local mouse = game:GetService("Players").LocalPlayer:GetMouse()

   local iconStack = {""}
   local iconStackCount = 1

   function RbxMouse:GetIcon()
      return mouse.Icon
   end

   function RbxMouse:SetIcon(icon)
      if type(icon) == "string" or icon == nil then
         iconStack[1] = icon or ""
         if iconStackCount == 1 then
            mouse.Icon = iconStack[1]
         end
      else
         error(("Icon 'icon' is not a string (received value %s of type %s)")
            :format(tostring(icon), typeof(icon)), 2)
      end
   end

   function RbxMouse:PushIcon(icon)
      if type(icon) == "string" or icon == nil then
         iconStackCount += 1
         iconStack[iconStackCount] = icon or ""
         mouse.Icon = iconStack[iconStackCount]
      else
         error(("Argument 'icon' is not a string (received value %s of type %s)")
            :format(tostring(icon), typeof(icon)), 2)
      end
   end

   function RbxMouse:PopIcon(icon)
      if icon == nil or type(icon) == "string" then
         if iconStackCount > 1 then
            if icon then
               for index = iconStackCount, 1, -1 do
                  if iconStack[index] == icon then
                     table.remove(iconStack, index)
                     iconStackCount -= 1
                     break
                  end
               end
            else
               iconStack[iconStackCount] = nil
               iconStackCount -= 1
            end
         end
         mouse.Icon = iconStack[iconStackCount]
      else
         error(("Argument 'icon' is not a string (received value %s of type %s)")
            :format(tostring(icon), typeof(icon)), 2)
      end
   end

   function RbxMouse:ClearAllIcons()
      iconStackCount = 1
      iconStack = {""}
      mouse.Icon = iconStack[1]
   end

   function RbxMouse:ClearIconStack()
      iconStackCount = 1
      iconStack = {iconStack[1]}
      mouse.Icon = iconStack[1]
   end
end

do
   local DEFAULT_MAX_DISTANCE = 1000

   function RbxMouse:GetRay(rayOptions)
      local camera = workspace.CurrentCamera
      local position
      local maxDistance
      if rayOptions then
         if rayOptions.Position then
            position = RbxMouse.Position
            if typeof(position) == "UDim2" then
               position = Vector2.new(
                  camera.ViewportSize.X*position.X.Scale + position.X.Offset,
                  camera.ViewportSize.Y*position.Y.Scale + position.Y.Offset
               )
            elseif typeof(position) == "Vector2" then
               position = rayOptions.Position
            else
               error(("Ray option 'ViewportPosition' must be a Vector2 or UDim2 (received value %s of type %s).")
                  :format(tostring(position), typeof(position)), 2)
            end
            if rayOptions.ApplyInset then
               position = RbxMouse:InsetToAbsolute(position)
            end
         else
            position = RbxMouse.Position
         end

         if rayOptions.MaxDistance then
            maxDistance = rayOptions.MaxDistance
            if type(maxDistance) ~= "number" then
               error(("Ray option 'MaxDistance' must be a number (received value %s of type %s.")
                  :format(tostring(maxDistance), typeof(maxDistance)), 2)
            end
         else
            maxDistance = DEFAULT_MAX_DISTANCE
         end
      else
         position = RbxMouse.Position
         maxDistance = DEFAULT_MAX_DISTANCE
      end

      local ray = camera:ViewportPointToRay(position.X, position.Y).Unit
      return Ray.new(ray.Origin, ray.Direction * maxDistance)
   end

   function RbxMouse:GetTarget(params, filter, ray, canMutateParams)
      if params == nil then
         params = RaycastParams.new()
         canMutateParams = true
      elseif typeof(params) ~= "RaycastParams" then
         error(("Argument 'params' must be a RaycastParams instance (received value %s of type %s).")
            :format(tostring(params), typeof(params), 2))
      end

      if filter ~= nil and type(filter) ~= "function" then
         error(("Argument 'filter' must be a function (received value %s of type %s).")
            :format(tostring(filter), typeof(filter)), 2)
      end

      if ray ~= nil then
         if type(ray) == "table" then
            ray = RbxMouse:GetRay(ray)
         elseif typeof(ray) ~= "Ray" then
            error(("Argument 'ray' must be a Ray or a table of ray options (received value %s of type %s).")
               :format(tostring(ray), typeof(ray), 2))
         end
      else
         ray = RbxMouse:GetRay()
      end
      return RbxMouse.Raycaster(ray.Origin, ray.Direction, params, filter, canMutateParams)
   end

   local function removeFromWhitelist(list, instance)
      -- Find and remove from the whitelist the ancestor that contains instance.
      local ancestor
      for index, item in pairs(list) do
         if item == instance or instance:IsDescendantOf(item) then
            ancestor = item
            table.remove(list, index)
            break
         end
      end
      if ancestor then
         -- Traverse the game tree from instance to ancestor, adding all children
         -- within the same ancestor to the whitelist except for the ancestors
         -- of the instance we're removing.
         local current = instance
         local listCount = #list
         while current and current ~= ancestor do
            for _, child in pairs(current.Parent:GetChildren()) do
               if child ~= current then
                  listCount += 1
                  list[listCount] = current
               end
            end
            current = current.Parent
         end
      end
   end

   function RbxMouse.Raycaster(origin, direction, raycastParams, filter, canMutateParams)
      local originalInstances = (not canMutateParams) and raycastParams.FilterDescendantsInstances
      local currentOrigin = origin
      local currentDirection = direction
      local result
      while true do
         result = workspace:Raycast(currentOrigin, currentDirection, raycastParams)
         if (not result) or (not filter) or filter(result, raycastParams, origin, direction) then
            break
         else
            -- Reduce the length of the ray so that it won't exceed the distance
            -- of the original ray.
            currentOrigin = result.Position
            currentDirection = direction-(currentOrigin-origin)

            -- Make the instance be ignored in the next raycast.
            if raycastParams.FilterType == Enum.RaycastFilterType.Blacklist then
               local newInstances = raycastParams.FilterDescendantsInstances
               newInstances[#newInstances+1] = result.Instance
               raycastParams.FilterDescendantsInstances = newInstances
            elseif raycastParams.FilterType == Enum.RaycastFilterType.Whitelist then
               raycastParams.FilterDescendantsInstances =
                  removeFromWhitelist(raycastParams.FilterDescendantsInstances, result.Instance)
            end
         end
      end
      if originalInstances then
         raycastParams.FilterDescendantsInstances = originalInstances
      end
      return result
   end

   function RbxMouse.FILTER_VISIBLE(result)
      return result.Instance.Transparency < 1
   end

   function RbxMouse.FILTER_CANCOLLIDE(result)
      return result.Instance.CanCollide
   end

   function RbxMouse.FILTER_VISIBLE_AND_CANCOLLIDE(result)
      return (result.Instance.Transparency < 1) and (result.Instance.CanCollide)
   end

   function RbxMouse.FILTER_VISIBLE_OR_CANCOLLIDE(result)
      return (result.Instance.Transparency < 1) or (result.Instance.CanCollide)
   end
end

return RbxMouse