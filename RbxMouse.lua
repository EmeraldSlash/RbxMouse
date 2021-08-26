--[[

RbxMouse v4.1
https://github.com/EmeraldSlash/RbxMouse

See repository for detailed documentation :)

-- Properties

bool RbxMouse.Button1                      [readonly]
bool RbxMouse.Button2                      [readonly]
bool RbxMouse.Button3                      [readonly]

array<InputObject> RbxMouse.Button1Inputs  [readonly]
array<InputObject> RbxMouse.Button2Inputs  [readonly]
array<InputObject> RbxMouse.Button3Inputs  [readonly]

Vector2 RbxMouse.Position                  [readonly]
Vector2 RbxMouse.InsetPosition             [readonly]

KeyCode RbxMouse.Button1KeyCode
KeyCode RbxMouse.Button2KeyCode
KeyCode RbxMouse.Button3KeyCode

-- Signals

RbxMouse.Button1Pressed(InputObject input, bool gameProcessed)
RbxMouse.Button2Pressed(InputObject input, bool gameProcessed)
RbxMouse.Button3Pressed(InputObject input, bool gameProcessed)

RbxMouse.Button1Released(float duration, InputObject input, bool gameProcessed)
RbxMouse.Button2Released(float duration, InputObject input, bool gameProcessed)
RbxMouse.Button3Released(float duration, InputObject input, bool gameProcessed)

RbxMouse.Scrolled(int direction, InputObject input, bool gameProcessed)
RbxMouse.ScrolledUp(int direction, InputObject input, bool gameProcessed)
RbxMouse.ScrolledDown(int direction, InputObject input, bool gameProcessed)

RbxMouse.Moved(Vector2 delta, InputObject input, bool gameProcessed)

-- Methods

bool RbxMouse:GetVisible()
void RbxMouse:SetVisible(bool visible)

float RbxMouse:GetSensitivity()
void RbxMouse:SetSensitivity(float sensitivity)

Vector2 RbxMouse:GetDelta()
bool RbxMouse:GetEnabled()
bool RbxMouse:IsButtonPressed(UserInputType mouseButton)
array<InputObject> RbxMouse:GetButtonsPressed()

bool RbxMouse:IsTouchUsingThumbstick(InputObject inputObject)
bool RbxMouse:IsInputNew(InputObject inputObject)

string RbxMouse:GetIcon()
void RbxMouse:SetIcon(string asset)
void RbxMouse:PushIcon(string asset)
void RbxMouse:PopIcon(optional string asset)
void RbxMouse:ClearAllIcons()
void RbxMouse:ClearIconStack()

MouseBehavior RbxMouse:GetBehavior()
void RbxMouse:SetBehavior(MouseBehavior behavior)

void RbxMouse:SetBehaviorEveryFrame(
   MouseBehavior behavior,
   optional int renderStepPriority
)
void RbxMouse:StopSettingBehaviorEveryFrame()

void RbxMouse:Fire<Signal>(<signalParameters>)

Ray RbxMouse:GetRay(number maxDistance, <Vector2|UDim2> position)

<void|RaycastResult> RbxMouse:GetTargetIgnore(
   optional array<Instance> ignoreList
)

<void|RaycastResult> RbxMouse:GetTarget(
   optional RaycastParams params,
   optional function filter,
   optional Ray ray,
   optional bool mutateParams
)

   filter: bool function (
      RaycastResult result,
      RaycastParams params,
      Vector3 origin,
      Vector3 direction
   )

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
      local topLeft = guiService:GetGuiInset()
      if typeof(position) == "Vector2" then
         position -= topLeft
      elseif typeof(position) == "UDim2" then
         position -= UDim2.fromOffset(topLeft.X, topLeft.Y)
      end
      return position
   end

   function RbxMouse:InsetToAbsolute(position)
      local topLeft = guiService:GetGuiInset()
      if typeof(position) == "Vector2" then
         position += topLeft
      elseif typeof(position) == "UDim2" then
         position += UDim2.fromOffset(topLeft.X, topLeft.Y)
      end
      return position
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

   RbxMouse.Button1 = false
   RbxMouse.Button2 = false
   RbxMouse.Button3 = false

   RbxMouse.Button1Inputs = {}
   RbxMouse.Button2Inputs = {}
   RbxMouse.Button3Inputs = {}

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
         RbxMouse.Button1Inputs[#RbxMouse.Button1Inputs+1] = input
         RbxMouse:FireButton1Pressed(input, gameProcessed)
      elseif (input.UserInputType == UIT_M2) or
         (input.KeyCode == RbxMouse.Button2KeyCode)
      then
         button2DownAt = os.clock()
         RbxMouse.Button2 = true
         RbxMouse.Button2Inputs[#RbxMouse.Button2Inputs+1] = input
         RbxMouse:FireButton2Pressed(input, gameProcessed)
      elseif (input.UserInputType == UIT_M3) or
         (input.KeyCode == RbxMouse.Button3KeyCode)
      then
         button3DownAt = os.clock()
         RbxMouse.Button3 = true
         RbxMouse.Button3Inputs[#RbxMouse.Button3Inputs+1] = input
         RbxMouse:FireButton3Pressed(input, gameProcessed)
      end
   end)

   userInputService.InputEnded:Connect(function(input, gameProcessed)
      if (input.UserInputType == UIT_M1) or
         (input.UserInputType == UIT_T) or
         (input.KeyCode == RbxMouse.Button1KeyCode)
      then
         RbxMouse.Button1 = false
         table.remove(RbxMouse.Button1Inputs, table.find(RbxMouse.Button1Inputs, input))
         RbxMouse:FireButton1Released(os.clock()-button1DownAt, input, gameProcessed)
      elseif (input.UserInputType == UIT_M2) or
         (input.KeyCode == RbxMouse.Button2KeyCode)
      then
         RbxMouse.Button2 = false
         table.remove(RbxMouse.Button2Inputs, table.find(RbxMouse.Button2Inputs, input))
         RbxMouse:FireButton2Released(os.clock()-button2DownAt, input, gameProcessed)
      elseif (input.UserInputType == UIT_M3) or
         (input.KeyCode == RbxMouse.Button3KeyCode)
      then
         RbxMouse.Button3 = false
         table.remove(RbxMouse.Button1Inputs, table.find(RbxMouse.Button2Inputs, input))
         RbxMouse:FireButton3Released(os.clock()-button3DownAt, input, gameProcessed)
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

         RbxMouse:FireMoved(delta, input, gameProcessed)
      elseif (input.UserInputType == UIT_MW) then
         RbxMouse:FireScrolled(input.Position.Z, input, gameProcessed)
         if (input.Position.Z > 0) then
            RbxMouse:FireScrolledUp(input.Position.Z, input, gameProcessed)
         elseif (input.Position.Z < 0) then
            RbxMouse:FireScrolledDown(input.Position.Z, input, gameProcessed)
         end
      end
   end)

   runService:BindToRenderStep("RbxMouseFrame", Enum.RenderPriority.First.Value, function()
      currentFrameId += 1
   end)
end

local function invalidArgument(index, name, correctType, value, depth)
   error(("Argument %d '%s' must be a %s (received value %s of type %s).")
      :format(index, name, correctType, tostring(value), typeof(value)), depth+1)
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
      if behavior ~= nil and typeof(behavior) ~= "MouseBehavior" then
         invalidArgument(1, 'behavior', 'MouseBehavior enum', behavior, 2)
      end
      userInputService.MouseBehavior = behavior
   end

   function RbxMouse:SetBehaviorEveryFrame(behavior, priority)
      if behavior ~= nil and typeof(behavior) ~= "MouseBehavior" then
         invalidArgument(1, 'behavior', 'MouseBehavior enum', behavior, 2)
      end
      if priority ~= nil and type(priority) ~= "number" then
         invalidArgument(2, 'priority', 'integer', priority, 2)
      end
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
         -- Only return the unlocked MouseDelta if it was updated this frame
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
   local PlayerModule = require(game:GetService("Players").LocalPlayer
      :WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))

   function RbxMouse:IsTouchUsingThumbstick(inputObject)
      local result = false
      if inputObject.UserInputType == Enum.UserInputType.Touch then
         local controls = PlayerModule:GetControls()
         if controls then
            local controller = controls:GetActiveController()
            if controller then
               result = (inputObject == controller.moveTouchObject)
            end
         end
      end
      return result
   end

   function RbxMouse:IsInputNew(inputObject)
      return inputObject.UserInputState == Enum.UserInputState.Begin
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
         invalidArgument(1, 'icon', 'string', icon, 2)
      end
   end

   function RbxMouse:PushIcon(icon)
      if type(icon) == "string" or icon == nil then
         iconStackCount += 1
         iconStack[iconStackCount] = icon or ""
         mouse.Icon = iconStack[iconStackCount]
      else
         invalidArgument(1, 'icon', 'string', icon, 2)
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
         invalidArgument(1, 'icon', 'string', icon, 2)
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

   function RbxMouse:GetRay(maxDistance, position)
      local camera = workspace.CurrentCamera

      if maxDistance then
         if type(maxDistance) ~= "number" then
            invalidArgument(1, 'maxDistance', 'number', maxDistance, 2)
         end
      else
         maxDistance = DEFAULT_MAX_DISTANCE
      end

      if position then
         if typeof(position) == "UDim2" then
            position = Vector2.new(
               camera.ViewportSize.X*position.X.Scale + position.X.Offset,
               camera.ViewportSize.Y*position.Y.Scale + position.Y.Offset
            )
         elseif typeof(position) == "Vector2" then
            position = position
         else
            invalidArgument(2, 'position', 'Vector2 or UDim2', position, 2)
         end
      else
         position = RbxMouse.Position
      end

      local ray = camera:ViewportPointToRay(position.X, position.Y).Unit
      return Ray.new(ray.Origin, ray.Direction * maxDistance)
   end

   function RbxMouse:GetTargetIgnore(ignoreList)
      if ignoreList ~= nil and type(ignoreList) ~= "table" then
         invalidArgument(1, 'ignoreList', 'list of Instances to ignore', ignoreList, 2)
      end
      local params = RaycastParams.new()
      if ignoreList then
         params.FilterType = Enum.RaycastFilterType.Blacklist
         params.FilterDescendantsInstances = ignoreList
      end
      local ray = RbxMouse:GetRay()
      return RbxMouse.Raycaster(ray.Origin, ray.Direction, params, nil, true)
   end

   function RbxMouse:GetTarget(params, filter, ray, mutateParams)
      if params == nil then
         params = RaycastParams.new()
         mutateParams = true
      elseif typeof(params) ~= "RaycastParams" then
         invalidArgument(1, 'params', 'RaycastParams instance', params, 2)
      end

      if filter ~= nil and type(filter) ~= "function" then
         invalidArgument(2, 'filter', 'function', filter, 2)
      end

      if ray ~= nil and typeof(ray) ~= "Ray" then
         invalidArgument(3, "ray", "Ray instance", ray, 2)
      else
         ray = RbxMouse:GetRay()
      end

      return RbxMouse.Raycaster(ray.Origin, ray.Direction, params, filter, mutateParams)
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

   function RbxMouse.Raycaster(origin, direction, raycastParams, filter, mutateParams)
      local originalInstances = (not mutateParams) and raycastParams.FilterDescendantsInstances
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