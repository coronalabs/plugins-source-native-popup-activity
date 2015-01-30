--*********************************************************************************************
-- ====================================================================
-- Corona SDK "Native Activity Popup" Sample Code
-- ====================================================================
--
-- File: main.lua
--
-- Version 1.0
--
-- Copyright (C) 2015 Corona Labs Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
-- Published changes made to this software and associated documentation and module files (the
-- "Software") may be used and distributed by Corona Labs, Inc. without notification. Modifications
-- made to this software and associated documentation and module files may or may not become
-- part of an official software release. All modifications made to the software will be
-- licensed under these same terms and conditions.
--*********************************************************************************************

-- Platforms: iOS

-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------

-- If we are on the simulator, show a warning that this plugin is only supported on device
local isSimulator = "simulator" == system.getInfo( "environment" )

if isSimulator then
	native.showAlert( "Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS device or Xcode simulator", { "OK" } )
end

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Require the widget library
local widget = require( "widget" )

-- Use the iOS 7 theme for this sample
widget.setTheme( "widget_theme_ios7" )

-- Display a background
local background = display.newImage( "world.jpg", display.contentCenterX, display.contentCenterY, true )


-------------------------------------------------------------------------------
-- Activity
-------------------------------------------------------------------------------

-- This is the name of the native popup to show, in this case we are showing the "social" popup
local popupName = "activity"

local dataType = "image"

local itemsByDataType =
{
	["image"] = {
		{
			type = "image",
			value = { filename = "world.jpg", baseDir = system.ResourceDirectory, }
		},
		{
			type = "image",
			value = { filename = "world2.jpg", baseDir = system.ResourceDirectory, }
		},
	},
	["text"] = {
		{ type = "string", value = "Hello, World" },
		{ type = "string", value = "Good night, and good luck" },
	},
	["url"] = 
	{
		{ type = "url", value = "http://www.coronalabs.com" },
		{ type = "url", value = "http://docs.coronalabs.com" },
	},
}

-- Executed upon touching & releasing a widget button
local function onButtonReleased( event )
	local key = event.target.label

	local isAvailable = native.canShowPopup( popupName )

	-- If it is possible to show the popup
	if isAvailable then
		local listener = {}
		function listener:popup( event )
			print( "name(" .. event.name .. ") type(" .. event.type .. ") activity(" .. tostring(event.activity) .. ") action(" .. tostring(event.action) .. ")" )
		end

		-- Show the popup
		native.showPopup( popupName,
		{
			items = itemsByDataType[dataType],
			-- excludedActivities = { "UIActivityTypeCopyToPasteboard", },
			listener = listener,
		})
	else
		if isSimulator then
			native.showAlert( "Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS/Android device or the Xcode simulator", { "OK" } )
		else
			-- Popup isn't available.. Show error message
			native.showAlert( "Cannot send " .. activityName .. " message.", "Please setup your " .. serviceName .. " account or check your network connection (on android this means that the package/app (ie Twitter) is not installed on the device)", { "OK" } )
		end
	end
end

-- Create a background to go behind our widget buttons
local buttonBackground = display.newRect( display.contentCenterX, 380, 220, 200 )
buttonBackground:setFillColor( 0 )

-- Create a facebook button
local button = widget.newButton
{
	label = "share",
	left = 0,
	top = 280,
	width = 240,
	onRelease = onButtonReleased,
}
button.x = display.contentCenterX

