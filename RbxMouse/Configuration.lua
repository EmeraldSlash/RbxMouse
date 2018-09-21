return {
    -- Raycast distance for the CFrame and Target properties
    RaycastDistance = 1000;

    -- Maximum number of seconds for a mouse button to be down for the click event to be called
    ClickThreshold = 0.5;

	-- Whether touch input is mapped to the first (left) mouse button
    DetectTouchAsButton1 = true;

    -- Whether the mouse has target functionality (Target and TargetFilter)
    TargetEnabled = true;

	-- Update properties with RunService and not mouse movemenet
	-- Less efficient than updating with mouse movement, but will update properties even if mouse hasn't been moved
	ConstantlyUpdatingProperties = true;
}
