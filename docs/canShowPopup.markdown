# native.canShowPopup() — Activity Plugin

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [Function][api.type.Function]
> __Library__           [native.*][api.library.native]
> __Return value__      [Boolean][api.type.Boolean]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          native, canShowPopup, social, Twitter, Facebook, Sina Weibo
> --------------------- ------------------------------------------------------------------------------------------


## Overview

Returns whether or not the popup type can be shown. 


## Syntax

	native.canShowPopup( name [, activityName] )

##### name ~^(required)^~
_[String][api.type.String]._ The string name of the popup to be shown. For the Activity plugin, use `"activity"`.

##### activityName ~^(optional)^~
_[String][api.type.String]._ The name of the activity. See the 'Supported Activities' in [native.showPopup()][plugin.CoronaProvider_native_popup_activity.showPopup] for valid string values.
