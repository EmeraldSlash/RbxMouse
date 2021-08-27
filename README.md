# RbxMouse v4.1

This library provides a consistent interface for all mouse related APIs.
Notable features:

- Mouse target detection involving a flexible raycasting system using the raycasting API. You can filter with ignore lists, collision groups, and any other arbitrary user-defined constraints.
- Accurate mouse delta is provided when MouseBehavior is not LockCenter.
- A simple stack for managing multiple mouse icons.
- Designed to work cross-platform and in many different contexts, able to manually fire mouse-related signals and listen to touch and gamepad/keyboard input.
- Helpers for working with touch input and button presses.

# Quick Reference

```
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

bool RbxMouse:BeginSingleInput(any key, InputObject inputObject)
void RbxMouse:EndSingleInput(any key, optional InputObject inputObject)

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

<void|RaycastResult> RbxMouse.Raycaster(
   Vector3 origin,
   Vector3 direction,
   RaycastParams raycastParams,
   optional function filter,
   optional bool mutateParams
)

Vector2 RbxMouse:AbsoluteToInset(Vector2 absolutePosition)
Vector2 RbxMouse:InsetToAbsolute(Vector2 insetPosition)

void RbxMouse:Fire<Signal>(<signalParameters>)

-- Filter function presets

bool RbxMouse.FILTER_VISIBLE(RaycastResult result)
bool RbxMouse.FILTER_CANCOLLIDE(RaycastResult result)
bool RbxMouse.FILTER_VISIBLE_AND_CANCOLLIDE(RaycastResult result)
bool RbxMouse.FILTER_VISIBLE_OR_CANCOLLIDE(RaycastResult result)
```

# Documentation
## Properties
```
bool RbxMouse.Button1
bool RbxMouse.Button2
bool RbxMouse.Button3
```

   These are true when the respective buttons are pressed, and false when not.
   If the player uses multiple inputs for a single button, the most recent
   inputs will affect the value.

   e.g. The sequence `left mouse button down -> touch start -> left mouse button
   up`, will result in RbxMouse.Button1 being `false` because the most recent
   input was `left mouse button up` even though the touch is still happening.

---

```
array<InputObject> RbxMouse.Button1Inputs
array<InputObject> RbxMouse.Button2Inputs
array<InputObject> RbxMouse.Button3Inputs
```

   An array of InputObjects currently active for each button. When an input
   starts (e.g. the left mouse button is pressed, or the player touches the
   touchscreen) its InputObject is added to the array. When an input finishes
   (e.g. the left mouse button is released or the player stops touching the
   screen) its InputObject is removed from the array.

---

```
Vector2 RbxMouse.Position
```

   The absolute position of the mouse on the screen. Top left corner of the
   screen will be `(0, 0)`.

---

```
Vector2 RbxMouse.InsetPosition
```

   The position of the mouse on the screen after accounting for GUI inset. Top
   left corner of the screen will be something like `(0, -36)`.

---

```
KeyCode RbxMouse.Button1KeyCode
KeyCode RbxMouse.Button2KeyCode
KeyCode RbxMouse.Button3KeyCode
```

   The optional KeyCodes that can trigger mouse button presses. Useful for
   gamepad support. Button1KeyCode defaults to `KeyCode.ButtonA`, the others to
   nil.

---

## Signals

```
RbxMouse.Button1Pressed(InputObject input, bool gameProcessed)
RbxMouse.Button2Pressed(InputObject input, bool gameProcessed)
RbxMouse.Button3Pressed(InputObject input, bool gameProcessed)
```

   These signals fire when mouse buttons begin being pressed. The `input`
   parameter can be used to determine the source of the button press(whether it
   was from the mouse, from a KeyCode, or from touch - and if so, which
   touch).

---

```
RbxMouse.Button1Released(float duration, InputObject input, bool gameProcessed)
RbxMouse.Button2Released(float duration, InputObject input, bool gameProcessed)
RbxMouse.Button3Released(float duration, InputObject input, bool gameProcessed)
```

   These signals fire when mouse buttons are released. The `duration` parameter
   tells you how many seconds the button was held down for. The `input`
   parameter can be used to determine the source of the button release
   (whether it was from the mouse, from a KeyCode, or from touch - and if so,
   which touch).

---

```
RbxMouse.Scrolled(int direction, InputObject input, bool gameProcessed)
RbxMouse.ScrolledUp(int direction, InputObject input, bool gameProcessed)
RbxMouse.ScrolledDown(int direction, InputObject input, bool gameProcessed)
```

   These signals fire when the mouse wheel is scrolled. `Scrolled` will fire for
   all scrolls, and `ScrolledUp` and `ScrolledDown` will fire when direction is
   positive and negative respectively. The direction the wheel was scrolled in
   is passed to all signals (not just Scrolled) for convenience.

---

```
RbxMouse.Moved(Vector2 delta, InputObject input, bool gameProcessed)
```

   This signal fires when the mouse is moved. The `delta` parameter describes
   how far in pixels the mouse moved, and is multiplied by the mouse
   sensitivity set by `RbxMouse:SetSensitivity()`.

---

## Methods

```
bool RbxMouse:GetVisible()
void RbxMouse:SetVisible(bool visible)
```

   Gets and sets whether the mouse icon is visible using
   `UserInputService.MouseIconEnabled`.

---

```
float RbxMouse:GetSensitivity()
void RbxMouse:SetSensitivity(float sensitivity)
```

   Gets and sets the mouse delta sensitivity. Mouse delta will be multiplied by
   this value when returned from `RbxMouse:GetDelta()` and `RbxMouse.Moved`.
   Note that this does NOT use `UserInputService.MouseDeltaSensitivity`,
   although RbxMouse still supports this property consistently regardless of
   MouseBehavior.

---

```
Vector2 RbxMouse:GetDelta()
```

   Returns `UserInputService:GetMouseDelta()` if the mouse is locked, otherwise if
   the mouse is free it returns the mouse delta this frame. Before being
   returned, the delta is multiplied by the mouse sensitivity set by
   `RbxMouse:SetSensitivity()`. Unlike the Roblox APIs, this delta will be
   nonzero regardless of MouseBehavior (not just when it is set to
   LockCenter).

---

```
bool RbxMouse:GetEnabled()
```

   Gets `UserInputService.MouseEnabled`, which is true if the user's device has
   a mouse available or false otherwise.

---

```
bool RbxMouse:IsButtonPressed(UserInputType mouseButton)
```

   Calls `UserInputService:IsMouseButtonPressed()`.

---

```
array<InputObject> RbxMouse:GetButtonsPressed()
```

   Calls `UserInputService:GetMouseButtonsPressed()`.

---

```
bool RbxMouse:IsTouchUsingThumbstick(InputObject inputObject)
```

   Returns true if the given input is currently using one of the touch
   thumbstick controls in the core scripts. Will return false if inputObject is
   a not a Touch input so you don't need to check that yourself. Useful if you
   want to ignore button presses(e.g. Rbxmouse.Button1Pressed or a GUI input
   event) from a specific touch when the player is the using the thumbstick.

---

```
bool RbxMouse:IsInputNew(InputObject inputObject)
```

   Returns true if the input is new. Useful for GUI input events where
   InputBegan will fire even if the mouse click or touch started outside of the
   button and moved into the button later, in which case you typically don't
   want buttons to register that as a press. This function is equivalent to
   inputObject.UserInputState == Enum.UserInputState.Begin.

---

```
bool RbxMouse:BeginSingleInput(any key, InputObject inputObject)
```

   Allows you to process only a single unique input for a specified key at a
   time (key can be an Instance, a string, or any other value used as keys in
   tables). Useful on mobile where the player can press multiple buttons at
   once. Returns true if the input should be processed, false if there is
   already another input active. Don't forget to call RbxMouse:EndSingleInput()
   when the input is considered finished! (Or when the key needs to be garbage
   collected to prevent memory leaks.)

---

```
void RbxMouse:EndSingleInput(any key, optional InputObject inputObject)
```

   Removes a previously begun input for a specified key. The inputObject
   parameter is optional, and if given will only remove it if it matches the
   active input for that key.

---

```
string RbxMouse:GetIcon()
```

   Gets the currently visible mouse icon.

---

```
void RbxMouse:SetIcon(string asset)
```

   Sets the mouse icon. If the stack methods are being used, this method will
   set the stack's default icon (i.e. the icon used when there is nothing in
   the stack) and will not override the visible icon in the stack.

---

```
void RbxMouse:PushIcon(string asset)
```

   Push an icon to the stack. This allows the mouse to have multiple icons at
   once, in priority of the order they were added to the stack (the most recent
   icon will be the one visible).

---

```
void RbxMouse:PopIcon(optional string asset)
```

   Pop an item from the stack. If an icon is provided, only items with that icon
   will be removed. This is useful if icons will be pushed to the stack in an
   unknown order and you want to remove only a specific icon.

---

```
void RbxMouse:ClearAllIcons()
```

   Clears the icon stack and removes the default icon set by
   `RbxMouse:SetIcon()`.

---

```
void RbxMouse:ClearIconStack()
```

   Clears the icon stack without removing the default icon set by
   `RbxMouse:SetIcon()`.

---

```
MouseBehavior RbxMouse:GetBehavior()
void RbxMouse:SetBehavior(MouseBehavior behavior)
```

   Gets and sets `UserInputService.MouseBehavior`.

---

```
void RbxMouse:SetBehaviorEveryFrame(MouseBehavior behavior, optional int renderStepPriority)
```

   Binds a callback using `RunService:BindToRenderStep()` that sets
   `UserInputService.MouseBehavior` to the behavior argument every frame. This
   is useful because mouse behaviour typically gets reset every frame by
   Roblox. This will be callback bound with priority
   `Enum.RenderPriority.Camera.Value - 1`, or `renderStepPriority` if it is
   given as an argument.

---

```
void RbxMouse:StopSettingBehaviorEveryFrame()
```

   Unbinds the above mouse behavior callback.

---

```
Ray RbxMouse:GetRay(
   optional float maxDistance,
   optional <Vector2|UDim2> position
)
```

   Creates a ray from the current mouse position. The ray will have a length of
   `maxDistance`(defaulting to 1000).

   If the `position` argument is provided, the ray will come from that position
   on the screen instead of the mouse position. This position does not include
   GUI inset, so the top left corner of the screen will always be `(0, 0)`.

   If your position is in is in inset (AKA 'screen') space, you can convert it
   first using `RbxMouse:InsetToAbsolute(position)` (see documentation further
   below).

---

```
<void|RaycastResult> RbxMouse:GetTargetIgnore(
   optional array<Instance> ignoreList
)
```

   Performs a raycast to get the current mouse target, ignoring instances
   (and their descendants) in the `ignoreList` argument if it is provided.

   Example:
   ```lua
   -- Raycast from current mouse position, hitting anything except instances
   -- that are inside the ignore list.
   local ignoreList = {instanceToIgnore}
   local result = RbxMouse:GetTargetIgnore(ignoreList)
   if result then
      -- a hit was detected
   end
   ```

---

```
<void|RaycastResult> RbxMouse:GetTarget(
   optional RaycastParams params,
   optional function filter,
   optional Ray ray,
   optional bool mutateParams
)
```

   Performs a raycast to get the current mouse target. This method allows much
   greater control over what a valid target will be, allowing the caller to
   specify what RaycastParams and Ray to use when performing the raycast. By
   default, `params` defaults to the default RaycastParams instance, and
   `ray` defaults to the current mouse position i.e. `RbxMouse:GetRay()`.

   This method also allows the caller to provide a filter function which will
   determine whether a raycast hit is valid (it should be returned) or not
   (it should be ignored and raycasting should continue). This function has the
   following signature:

```
bool filter (
   RaycastResult result,
   RaycastParams params,
   Vector3 origin,
   Vector3 direction
)
```

   All arguments to this function are guaranteed to not be nil. It should return
   true if the result should be considered a hit, false if not and the result
   should be ignored. RbxMouse provides four preset filters, documented further
   below.

   Lastly, the `mutateParams` argument is there to allow the caller to control
   whether the RaycasParams instance will have its FilterDescendantsInstances
   table permanently modified. By default, the argument is false and will not
   allow modifications, but there may be some occasions where you find it more
   efficient to allow FilterDescendantsInstances to be changed.

   Example:
   ```lua
   -- Raycast from current mouse position, hitting anything.
   local result = RbxMouse:GetTarget()
   if result then
      -- a hit was detected
   end
   ```

   For more examples, see the "Contrived examples" section below.

---

```
<void|RaycastResult> RbxMouse.Raycaster(
   Vector3 origin,
   Vector3 direction,
   RaycastParams raycastParams,
   optional function filter,
   optional bool mutateParams
)
```

   The function that is actually used to perform raycasts once all data is
   ready. This can be overwritten with your own custom raycasting function if
   you wish. The first three arguments are part of the normal
   `workspace:Raycast()` API. See documentation for `RbxMouse:GetTarget()` for
   the last two parameters.

---

```
Vector2 RbxMouse:AbsoluteToInset(Vector2 absolutePosition)
Vector2 RbxMouse:InsetToAbsolute(Vector2 insetPosition)
```

   Utility functions for converting between absolute space (WITHOUT the GUI
   inset, AKA "Viewport" in Roblox APIs) and inset space (WITH the GUI inset,
   AKA "Screen" in Roblox APIs).

---

```
void RbxMouse:Fire<Signal>(... signalParameters)
```

   Fires a RbxMouse signal with the name after 'Fire'. Signal parameters is a
   tuple of any values which will be passed to the signal callbacks. Make sure
   to check they are of the correct type and are in the right order.

   Examples:
   ```lua
   RbxMouse:FireButton1Pressed(mouseButton1InputObject, true)

   RbxMouse:FireButton3Released(1.5, mouseButton1InputObject, true)

   RbxMouse:FireMoved(Vector2.new(10, 10), moveInputObject, true)
   ```

   Some of these signals require InputObjects, which are not creatable by
   scripts. How you deal with is entirely up to you, as RbxMouse does not use
   these signals internally.

   For example, you could pass in a dummy table (pretending to be an InputObject
   with the properties your callbacks use) or `nil`. Passing in `nil` may be
   useful as a convention so that your callbacks can know when the signal has
   been fired manually:

   ```lua
      RbxMouse.Button1Pressed:Connect(function(inputObject, gameProcessed)
         if not inputObject then
            -- we reach here if the signal was fired manually by your code
         else
            -- otherwise we know this was triggered by real user input
         end
      end)

      RbxMouse:FireButton1Pressed(nil, true)
   ```

---

## Filter function presets

Four predefined filter functions for use in the `filter` argument for `RbxMouse:GetTarget()` and `RbxMouse.Raycaster`.

---

```
bool RbxMouse.FILTER_VISIBLE(RaycastResult result)
```

   Only hit parts with Transparency < 1

---

```
bool RbxMouse.FILTER_CANCOLLIDE(RaycastResult result)
```

   Only hit parts with CanCollide == true

---

```
bool RbxMouse.FILTER_VISIBLE_AND_CANCOLLIDE(RaycastResult result)
bool RbxMouse.FILTER_VISIBLE_OR_CANCOLLIDE(RaycastResult result)
```

   Self explanatory combinations of the above

---

# Contrived examples

Perform a simple raycast, hitting anything:

```lua
local result = RbxMouse:GetTarget()
```

More complicated raycasting with RaycastParams, a filter function, and a ray:
```lua
-- Ignore the player's character.
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}

-- Raycast from any 3D origin in any 3D direction (stopping after length of direction).
local ray = Ray.new(origin, direction)

-- Only hit instances that have CanCollide = true.
local result = RbxMouse:GetTarget(params, RbxMouse.FILTER_CANCOLLIDE, ray)
```

As you can see, RbxMouse is flexible enough that you can use it as a
raycasting library in its own right.

Raycasting from center of screen and only hitting very specific parts:

```lua
-- Only hit instances named "HitMe" and with "CanHit" attribute set to boolean value true.
local function customFilter(result, params, origin, direction)
   return
      (result.Instance.Name == "HitMe") and
      (result.Instance:GetAttribute("CanHit") == true)
end

-- Raycast from the center of the screen and with a max distance of 512 studs.
local ray = RbxMouse:GetRay(512, workspace.CurrentCamera.ViewportSize/2)

-- No raycast params, so it will hit anything as long as the customFilter function accepts the hit.
local result = RbxMouse:GetTarget(nil, customFilter, ray)
```

Using the mouse icon stack:

```lua
local DEFAULT_ICON = "rbxassetid://6978852551"
local LEFT_ICON = "rbxassetid://6733999189"
local RIGHT_ICON = "rbxassetid://6733496085"

RbxMouse:SetIcon(DEFAULT_ICON)

RbxMouse.Button1Pressed:Connect(function()
   RbxMouse:PushIcon(LEFT_ICON)
end)
RbxMouse.Button1Released:Connect(function()
   RbxMouse:PopIcon(LEFT_ICON)
end)

RbxMouse.Button2Pressed:Connect(function()
   RbxMouse:PushIcon(RIGHT_ICON)
end)
RbxMouse.Button2Released:Connect(function()
   RbxMouse:PopIcon(RIGHT_ICON)
end)

RbxMouse.Button3Pressed:Connect(function()
   RbxMouse:ClearIconStack()
end)
```

Ignoring taps on the screen when using thumbstick:

```lua
RbxMouse.Button1Pressed:Connect(function(inputObject)
   if not RbxMouse:IsTouchUsingThumbstick(inputObject) then
      -- Your code here
   end
end)
```

Prevent buttons being pressed by a click/tap starting elsewhere then being
dragged onto the button:

```lua
local button = gui.TextButton

button.InputBegan:Connect(function(inputObject)
   if inputObject.UserInputType == Enum.UserInputType.Touch or
      inputObject.UserInputType == Enum.UserInputType.MouseButton1
   then
      if BbxMouse:IsInputNew(inputObject) then
         -- Your code here
      end
   end
end)
```

Only allow a button to be pressed by a single finger at once on mobile:

```lua
local button = gui.TextButton

button.InputBegan:Connect(function(inputObject)
   if inputObject.UserInputType == Enum.UserInputType.Touch then
      if RbxMouse:BeginSingleInput(button, inputObject) then
         -- Your code here
      end
   end
end)

button.InputEnded:Connect(function(inputObject)
   if inputObject.UserInputType == Enum.UserInputType.Touch then
      RbxMouse:EndSingleInput(button, inputObject)
   end
end)
```

Mouse movement w/ terrible first person camera:

```lua
local MIN_Y = -math.pi/2.1
local MAX_Y = math.pi/2.1

local camera = workspace.CurrentCamera
local angleX = 0
local angleY = 0

-- Lock the mouse in the center of the screen, hide the icon, and set the sensitivity
RbxMouse:SetBehaviorEveryFrame(Enum.MouseBehavior.LockCenter)
RbxMouse:SetVisible(false)
RbxMouse:SetSensitivity(0.002)

RbxMouse.Moved:Connect(function(delta)
   -- Use mouse delta (which is in pixel units) to modify camera angle
   angleX = angleX - delta.X
   angleY = math.clamp(angleY - delta.Y, MIN_Y, MAX_Y)
end)

game:GetService("RunService").RenderStepped:Connect(function()
   local character = game.Players.LocalPlayer.Character
   if character then
      local head = character:FindFirstChild("Head")
      if head then
         camera.CameraType = Enum.CameraType.Scriptable
         camera.Focus = CFrame.new(head.Position)
         local offset = Vector3.new(
            math.sin(angleX)*math.cos(angleY),
            math.sin(angleY),
            math.cos(angleX)*math.cos(angleY)
         )
         camera.CFrame = CFrame.lookAt(head.Position, head.Position + offset)
      else
         camera.CameraType = Enum.CameraType.Custom
      end
   else
      camera.CameraType = Enum.CameraType.Custom
   end
end)
```

Finding player on click:

```lua
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local players = game:GetService("Players")

RbxMouse.Button1Pressed:Connect(function()
   -- Cast a ray that only hits parts with Transparency < 1 and CanCollide == true.
   local targetResult = RbxMouse:GetTarget(raycastParams, RbxMouse.FILTER_VISIBLE_AND_CANCOLLIDE)
   if targetResult and targetResult.Instance then
      local targetPlayer = players:GetPlayerFromCharacter(targetResult.Instance.Parent)
      if targetPlayer then
         print(("Hit part %s (of player %s)")
            :format(targetResult.Instance.Name, targetPlayer.Name))
      else
         print(("Hit part %s")
            :format(targetResult.Instance.Name))
      end
   end
end)
```