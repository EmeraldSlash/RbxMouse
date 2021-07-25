# RbxMouse v4.0

This library provides a consistent interface for all mouse related APIs.
Notable features:

- Mouse target detection involving a flexible raycasting system using the raycasting API. You can filter with ignore lists, collision groups, and any other arbitrary user-defined constraints.
- Accurate mouse delta is provided when MouseBehavior is not LockCenter.
- A simple stack for managing multiple mouse icons.
- Designed to work cross-platform and in many different contexts, able to manually fire mouse-related signals and listen to touch and gamepad/keyboard input.

# Quick Reference

```
-- Properties

bool RbxMouse.Button1				[readonly]
bool RbxMouse.Button2				[readonly]
bool RbxMouse.Button3				[readonly]

KeyCode RbxMouse.Button1KeyCode
KeyCode RbxMouse.Button2KeyCode
KeyCode RbxMouse.Button3KeyCode

Vector2 RbxMouse.Position			[readonly]
Vector2 RbxMouse.InsetPosition		[readonly]

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
```

# Documentation
## Properties
```
bool RbxMouse.Button1
bool RbxMouse.Button2
bool RbxMouse.Button3
```

   These are true when the respective buttons are pressed, and false when not.

---

```
KeyCode RbxMouse.Button1KeyCode
KeyCode RbxMouse.Button2KeyCode
KeyCode RbxMouse.Button3KeyCode
```

   The optional KeyCodes that can trigger mouse button presses. Useful for gamepad support. Button1KeyCode defaults to `KeyCode.ButtonA`, the others to nil.

---

```
Vector2 RbxMouse.Position
```

   The absolute position of the mouse on the screen. Top left corner of the screen will be `(0, 0)`.

---

```
Vector2 RbxMouse.InsetPosition
```

   The position of the mouse on the screen after accounting for GUI inset. Top left corner of the screen will be something like `(0, -36)`.

---

## Signals

```
RbxMouse.Button1Pressed(bool gameProcessed, InputObject input)
RbxMouse.Button2Pressed(bool gameProcessed, InputObject input)
RbxMouse.Button3Pressed(bool gameProcessed, InputObject input)
```

   These signals fire when mouse buttons begin being pressed. The `input` parameter can be used to determine the source of the button press (whether it was from the mouse, from a KeyCode, or from touch - and if so, which touch).

---

```
RbxMouse.Button1Released(float duration, bool gameProcessed, InputObject input)
RbxMouse.Button2Released(float duration, bool gameProcessed, InputObject input)
RbxMouse.Button3Released(float duration, bool gameProcessed, InputObject input)
```

   These signals fire when mouse buttons are released. The duration argument tells you how many seconds the button was held down for. The `input` parameter can be used to determine the source of the button release (whether it was from the mouse, from a KeyCode, or from touch - and if so, which touch).

---

```
RbxMouse.Scrolled(int direction, bool gameProcessed, InputObject input)
RbxMouse.ScrolledUp(int direction, bool gameProcessed, InputObject input)
RbxMouse.ScrolledDown(int direction, bool gameProcessed, InputObject input)
```

   These signals fire when the mouse wheel is scrolled. `Scrolled` will fire for all scrolls, and `ScrolledUp` and `ScrolledDown` will fire when direction is positive and negative respectively. The direction the wheel was scrolled in is passed to all signals (not just Scrolled) for convenience.

---

```
RbxMouse.Moved(Vector2 delta, bool gameProcessed, InputObject input)
```

   This signal fires when the mouse is moved. The `delta` parameter describes how far in pixels the mouse moved, and is multiplied by the mouse sensitivity set by `RbxMouse:SetSensitivity()`.

---

## Methods

```
string RbxMouse:GetIcon()
```

   Gets the currently visible mouse icon.

---

```
void RbxMouse:SetIcon(string asset)
```

   Sets the mouse icon. If the stack methods are being used, this method will set the stack's default icon (i.e. the icon used when there is nothing in the stack) and will not override the visible icon in the stack.

---

```
void RbxMouse:PushIcon(string asset)
```

   Push an icon to the stack. This allows the mouse to have multiple icons at once, in priority of the order they were added to the stack (the most recent icon will be the one visible).

---

```
void RbxMouse:PopIcon(optional string asset)
```

   Pop an item from the stack. If an iconicon is provided, only items with that icon will be removed. This is useful if icons will be pushed to the stack in an unknown order and you want to remove only a specific icon.

---

```
void RbxMouse:ClearAllIcons()
```

   Clears the icon stack and removes the default icon set by `RbxMouse:SetIcon()`.

---

```
void RbxMouse:ClearIconStack()
```

   Clears the icon stack without removing the default icon set by `RbxMouse:SetIcon()`.

---

```
bool RbxMouse:GetVisible()
void RbxMouse:SetVisible(bool visible)
```

   Gets and sets whether the mouse icon is visible using `UserInputService.MouseIconEnabled`.

---

```
MouseBehavior RbxMouse:GetBehavior()
void RbxMouse:SetBehavior(MouseBehavior behavior)
```

   Gets and sets UserInputService.MouseBehavior.

---

```
void RbxMouse:SetBehaviorEveryFrame(MouseBehavior behavior, optional int renderStepPriority)
```

   Binds a callback using `RunService:BindToRenderStep()` that sets `UserInputService.MouseBehavior` to the behavior argument every frame. This is useful because mouse behaviour typically gets reset every frame by Roblox. This will be callback bound with priority `Enum.RenderPriority.Camera.Value - 1`, or `renderStepPriority` if it is given as an argument.

---

```
void RbxMouse:StopSettingBehaviorEveryFrame()
```

   Unbinds the mouse behavior callback mentioned above.

---

```
float RbxMouse:GetSensitivity()
void RbxMouse:SetSensitivity(float sensitivity)
```

   Gets and sets the mouse delta sensitivity. Mouse delta will be multiplied by this value when returned from `RbxMouse:GetDelta()` and `RbxMouse.Moved`. Note that this does NOT use `UserInputService.MouseDeltaSensitivity`, although RbxMouse still supports this property consistently regardless of MouseBehavior.

---

```
bool RbxMouse:GetEnabled()
```

   Gets `UserInputService.MouseEnabled`.

---

```
Vector2 RbxMouse:GetDelta()
```

   Returns `UserInputService.MouseDelta` if the mouse is locked, otherwise if the mouse is free it returns the mouse delta this frame. The return value is multiplied by the mouse sensitivity set by `RbxMouse:SetSensitivity()`. Unlike the Roblox APIs, this delta will be nonzero regardless of MouseBehavior (not just when it is set to LockCenter).

---

```
array<InputObject> RbxMouse:GetButtonsPressed()
```

   Calls `UserInputService:GetMouseButtonsPressed()`.

---

```
bool RbxMouse:IsButtonPressed(UserInputType mouseButton)
```

   Calls `UserInputService:IsMouseButtonPressed()`.

---

```
void RbxMouse:Fire<Signal>(<signalParameters>)
```

   e.g. `RbxMouse:FireButton1Pressed(false, true, false)`

---

```
Ray RbxMouse:GetRay(optional table rayOptions)
```

   Creates a ray based on the current mouse position. The rayOptions table
   allows you to specify the following optional parameters:

```
float MaxDistance
	The maximum distance that targets will be within i.e. the length of the
	ray. Defaults to 1000.

<Vector2|UDim2> Position
	The absolute position on the screen to create the ray from. Does not
	account for GUI inset, so (0, 0) will always be the top left corner of
    the screen. Defaults to the current mouse position.

bool ApplyInset
	If true, GUI inset will be added to Position so that the value
	necessary to represent the top left corner of the screen becomes
	something like (0, -36). Defaults to false.
```

Example usage with rayOptions:

```lua
RbxMouse:GetRay({
	MaxDistance = 512;
    Position = Vector2.new(100, 100);
    UseInset = true;
})
```

---

```
<void|RaycastResult> RbxMouse:GetTarget(
   optional RaycastParams params,
   optional function filter,
   optional <Ray|table> ray,
   optional bool canMutateParams
)
```
   Performs a raycast to get the current mouse target. The params argument can
   either be a RaycastParams instance, or a table containing the members of
   RaycastParams to set on a new RaycastParams instance. If not given, this
   will be the default RaycastParams.

   The filter argument is a function that determines whether a raycast hit is
   valid, or if it should be ignored. It has arguments passed to it:

```
bool filter (RaycastResult result, RaycastParams params, Vector3 origin, Vector3 direction)
```

   All arguments to this function are guaranteed to not be nil. Returns true if the result should be considered a hit, false if not and the result should be
   ignored.

   The `ray` argument should either be a Ray instance, or a `raycastOptions` table
   to be passed to `RbxMouse:GetRay()`. If not given, this will default to the
   result of the call to `RbxMouse:GetRay()` - in other words, the ray from the
   mouse's current position.

   The `canMutateParams` argument is to be passed to the raycaster function. This
   defines whether the RaycastParams instance given can have its
   FilterDescendantsInstances list be mutated when performing the raycast. This
   defaults to false, which is useful if you want to reuse the same
   RaycastParams instance across multiple raycasts. Set it to true if you are
   just calling the method once with a new RaycastParams instance that won't be
   used again to save some table copying.

---

```
<void|RaycastResult> RbxMouse.Raycaster(
   Vector3 origin,
   Vector3 direction,
   RaycastParams raycastParams,
   optional function filter,
   optional bool canMutateParams
)
```

   The function that is actually used to perform raycasts once all data is
   ready. This can be overwritten with your own custom raycasting function if
   you wish. The first three arguments are part of the normal `workspace:Raycast()` API. See documentation for `RbxMouse:GetTarget()` for the last two
   parameters.

--

```
Vector2 RbxMouse:AbsoluteToInset(Vector2 absolutePosition)
Vector2 RbxMouse:InsetToAbsolute(Vector2 insetPosition)
```

   Utility functions for converting between absolute space (WITHOUT the GUI
   inset, AKA "Viewport" in Roblox APIs) and inset space (WITH the GUI inset,
   AKA "Screen" in Roblox APIs).

---

## Filter function presets

Four predefined filter functions for use in the GetTarget/Raycaster filter
parameter.

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

Simple mouse target:

```lua
-- Raycast from current mouse position, hitting anything.
local result = RbxMouse:GetTarget()
```

Raycasting with any ray, RaycastParams, and a filter function:

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

Raycasting from center of screen and only hitting very specific parts:

```lua
-- Only hit instances named "HitMe" and with "CanHit" attribute set to boolean value true.
local function customFilter(result, params, origin, direction)
	return
 	   (result.Instance.Name == "HitMe") and
       (result.Instance:GetAttribute("CanHit") == true)
end

local ray = {
	-- Will not find any hits further than 512 studs.
	MaxDistance = 512;
	-- Raycast from center of the screen.
	Position = workspace.CurrentCamera.ViewportSize/2;
}

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

# Features in consideration

- Keeping track of all InputObjects that are active and only performing certain actions when InputObjects are equal. On the user-facing side, this would require more than a single ``RbxMouse.Button*` boolean property for each button. Mostly only useful for touch input, or customisable handling of input method changes during runtime.
- Allow multiple different KeyCodes to trigger each button. Will probably make the `RbxMouse.Button*KeyCode` properties arrays instead of single values.