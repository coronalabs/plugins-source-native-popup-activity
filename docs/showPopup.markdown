# native.showPopup() — Activity Plugin

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [function][api.type.function]
> __Library__           [native.*][api.library.native]
> __Return value__      none
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          native, showPopup, social, Twitter, Facebook, Sina Weibo
> --------------------- ------------------------------------------------------------------------------------------

## Overview

Displays the activity popup window which corresponds to 'UIActivityViewController' on iOS. The set of activities depends on the type of items you provide.


## Syntax

	native.showPopup( name, options )

##### name ~^(required)^~
_[String][api.type.String]._ The string name of the popup to be shown. To trigger this Activity plugin, use `"activity"`.

##### options ~^(required)^~
_[Table][api.type.Table]._ A table that specifies parameters for the popup — see 'Options References' below for more details.


## Options Reference

##### items ~^(required)^~
_[Array][api.type.Array]._ Array of individual items. See 'Item Table' below

##### excludedActivities ~^(optional)^~
_[Array][api.type.Array]._ By default, all built-in activities are shown. You can exclude an activity by specifying an array of strings, each string corresponding to an activity. See the 'Supported Activites' below for valid string values.

##### listener ~^(optional)^~
_[Listener][api.type.Listener] Listener which supports the basic [popup events][api.event.popup]. In addition, it supports the following additional properties:

* an `"action"` property: `"sent"` or `"cancelled"`
* an `"activity"` property that corresponds to one of the strings in 'Supported Activites' below.


## Item Table

An individual item is a [table][api.type.Table] that contains data on which an activity is to be performed.

This table must contain both `type` and `value` properties. 

Different activities support different item types. Please refer to Apple's [Built-in Activity Types](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIActivity_Class/index.html#//apple_ref/doc/constant_group/Built_in_Activity_Types)
for a reference of types supported for a particular activity.

The following are valid types and an explanation of the expected value:

* `"string"` The value should be a [string][api.type.String]. It will be converted to a NSString.
* `"url"` The value should be a [string][api.type.String]. It will be converted to a NSURL.
* `"image"` The corresponding value is a Lua table `{ baseDir=, filename= }` pointing to the image file you wish to post. It will be converted to an UIImage.
* `"color"` The corresponding value is an array of color channels (see [Paint][api.type.Paint]). It will be converted to an UIColor.
* `"dictionary"` The corresponding value is a [table][api.type.Table]. It will be converted to a NSDictionary.


## Supported Activities

This plugin supports the following activity string values (each string, corresponding to a built-in activity on iOS):

* `"postToFacebook"` (UIActivityTypePostToFacebook)
* `"postToTwitter"` (UIActivityTypePostToTwitter)
* `"postToWeibo"` (UIActivityTypePostToWeibo)
* `"message"` (UIActivityTypeMessage)
* `"mail"` (UIActivityTypeMail)
* `"print"` (UIActivityTypePrint)
* `"copyToPasteboard"` (UIActivityTypeCopyToPasteboard)
* `"assignToContact"` (UIActivityTypeAssignToContact)
* `"saveToCameraRoll"` (UIActivityTypeSaveToCameraRoll)
* `"addToReadingList"` (UIActivityTypeAddToReadingList)
* `"postToFlickr"` (UIActivityTypePostToFlickr)
* `"postToVimeo"` (UIActivityTypePostToVimeo)
* `"postToTencentWeibo"` (UIActivityTypePostToTencentWeibo)
* `"airDrop"` (UIActivityTypeAirDrop)

You should consult the [iOS UIActivity API Docs](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIActivity_Class/index.html#//apple_ref/doc/constant_group/Built_in_Activity_Types) for valid item types the can be used for the above built-in activities.


## Example

### String Items

`````lua
local popupListener = {}
function popupListener:popup( event )
	print(
		"(name, type, activity, action):", 
		event.name, event.type, tostring(event.activity, tostring(event.action) )
end

local textItems = {
	{ type = "string", value = "Hello, World" },
	{ type = "string", value = "Good night, and good luck" },
},

local options = { items = textItems, listener = popupListener, }
native.showPopup( "activity", options )
`````


### URL Items

`````lua
local popupListener = {}
function popupListener:popup( event )
	print(
		"(name, type, activity, action):", 
		event.name, event.type, tostring(event.activity, tostring(event.action) )
end

local urlItems = {
	{ type = "url", value = "http://www.coronalabs.com" },
	{ type = "url", value = "http://docs.coronalabs.com" },
},

local options = { items = urlItems, listener = popupListener, }
native.showPopup( "activity", options )
`````


### Image Items

`````lua
local popupListener = {}
function popupListener:popup( event )
	print(
		"(name, type, activity, action):", 
		event.name, event.type, tostring(event.activity, tostring(event.action) )
end

local imageItems = {
	{
		type = "image",
		value = { filename = "world.jpg", baseDir = system.ResourceDirectory, }
	},
	{
		type = "image",
		value = { filename = "world2.jpg", baseDir = system.ResourceDirectory, }
	},
},

local options = { items = imageItems, listener = popupListener, }
native.showPopup( "activity", options )
`````
