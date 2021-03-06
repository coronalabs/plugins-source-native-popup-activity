//
//  IOSActivityPluginUtils.h
//
//  Copyright (c) 2015 CoronaLabs Inc. All rights reserved.
//

#ifndef _IOSActivityPluginUtils_H__
#define _IOSActivityPluginUtils_H__

#include "CoronaLua.h"
#include "CoronaMacros.h"

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------

@class NSArray;
@class NSDictionary;
@class NSError;
@class NSString;
@class NSURL;
@class UIImage;

namespace Corona
{

// ----------------------------------------------------------------------------

class IOSActivityPluginUtils
{
	public:
		typedef IOSActivityPluginUtils Self;

	public:
		static void PushEvent( lua_State *L, const char *luaActivityType, BOOL completed, NSArray *returnedItems, NSError *activityError );

		static NSString *ToFilePath( lua_State *L, int index );

		static UIImage *ToUIImage( lua_State *L, int index );

		static NSString *ToNSString( lua_State *L, int index );
	
		static NSURL *ToNSURL( lua_State *L, int index );
	
		static NSString *ToUIActivityType( lua_State *L, int index );

		static const char *ToLuaActivityType( NSString *uiKitActivityType );

		static NSArray *ToUIActivityTypeArray( lua_State *L, int index, const char *errorLabel = NULL );

		static id ToItemValue( lua_State *L, int index, const char *itemType );

		static NSArray *ToItemArray( lua_State *L, int index, const char *errorLabel = NULL );
};

// ----------------------------------------------------------------------------

} // namespace Corona

// ----------------------------------------------------------------------------

#endif // _IOSActivityPluginUtils_H__
