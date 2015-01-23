# native.* — Activity Plugin

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [CoronaProvider][api.type.CoronaProvider]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          native, showPopup, social, Twitter, Facebook, Sina Weibo
> __Availability__      Pro, Enterprise
> __Platforms__			Android, iOS
> --------------------- ------------------------------------------------------------------------------------------

## Overview

This plugin is a _provider_ plugin that extends the functionality of native.showPop()

In particular, this provider plugin displays the activity popup window which corresponds to 'UIActivityViewController' on iOS.


## Syntax

	local activity = require( "CoronaProvider.native.popup.activity" )


## Functions

#### [native.showPopup()][plugin.CoronaProvider_native_popup_activity.showPopup]
#### [native.canShowPopup()][plugin.CoronaProvider_native_popup_activity.canShowPopup]


## Project Settings

To use this plugin, add an entry into the `plugins` table of `build.settings`. When added, the build server will integrate the plugin during the build phase.

``````lua
settings =
{
	plugins =
	{
		["CoronaProvider.native.popup.activity"] =
		{
			publisherId = "com.coronalabs"
		},
	},
}
``````


## Sample Code

TBD

## Support

* [Corona Forums](http://forums.coronalabs.com/forum/631-corona-premium-plugins/)