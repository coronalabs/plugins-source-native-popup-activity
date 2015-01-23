//
//  IOSActivityNativePopupProvider.h
//
//  Copyright (c) 2013 CoronaLabs Inc. All rights reserved.
//

#ifndef _IOSActivityNativePopupProvider_H__
#define _IOSActivityNativePopupProvider_H__

#include "CoronaLua.h"
#include "CoronaMacros.h"

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_CoronaProvider_native_popup_activity( lua_State *L );

#endif // _IOSActivityNativePopupProvider_H__
