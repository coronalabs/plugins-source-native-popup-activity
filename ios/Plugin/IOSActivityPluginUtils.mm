//
//  IOSActivityPluginUtils.mm
//
//  Copyright (c) 2015 CoronaLabs Inc. All rights reserved.
//

#include "IOSActivityPluginUtils.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CoronaRuntime.h"
#include "CoronaAssert.h"
#include "CoronaEvent.h"
#include "CoronaLua.h"
#include "CoronaLuaIOS.h"
#include "CoronaLibrary.h"

#include "IOSActivityNativePopupProvider+Private.h"

// ----------------------------------------------------------------------------

namespace Corona
{

// ----------------------------------------------------------------------------

static const char *kEventName = CoronaEventPopupName();

// ----------------------------------------------------------------------------

static NSDictionary *
UIActivityForLuaStringMapping()
{
	static NSDictionary *sMapping = nil;

	if ( ! sMapping )
	{
		NSDictionary *mapping_v6 = @{
			@"UIActivityTypePostToFacebook" : UIActivityTypePostToFacebook,
			@"UIActivityTypePostToTwitter" : UIActivityTypePostToTwitter,
			@"UIActivityTypePostToWeibo" : UIActivityTypePostToWeibo,
			@"UIActivityTypeMessage" : UIActivityTypeMessage,
			@"UIActivityTypeMail" : UIActivityTypeMail,
			@"UIActivityTypePrint" : UIActivityTypePrint,
			@"UIActivityTypeCopyToPasteboard" : UIActivityTypeCopyToPasteboard,
			@"UIActivityTypeAssignToContact" : UIActivityTypeAssignToContact,
			@"UIActivityTypeSaveToCameraRoll" : UIActivityTypeSaveToCameraRoll,
		};

		NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithDictionary:mapping_v6];

		if ( nil != UIActivityTypeAddToReadingList )
		{
			// Activity types introduced in iOS 7.0
			NSDictionary *mapping_v7 = @{
				@"UIActivityTypeAddToReadingList" : UIActivityTypeAddToReadingList,
				@"UIActivityTypePostToFlickr" : UIActivityTypePostToFlickr,
				@"UIActivityTypePostToVimeo" : UIActivityTypePostToVimeo,
				@"UIActivityTypePostToTencentWeibo" : UIActivityTypePostToTencentWeibo,
				@"UIActivityTypeAirDrop" : UIActivityTypeAirDrop,
			};

			[mapping addEntriesFromDictionary:mapping_v7];
		}

		sMapping = [mapping retain];
	}

	return sMapping;
}

static NSDictionary *
LuaStringForUIActivityMapping()
{
	static NSDictionary *sMapping = nil;

	if ( ! sMapping )
	{
		NSDictionary *reverseMapping = UIActivityForLuaStringMapping();

		NSMutableDictionary *mapping = [NSMutableDictionary dictionary];

		for ( NSString *key in reverseMapping )
		{
			// Invert key/value
			mapping[reverseMapping[key]] = key;
		}

		sMapping = [mapping retain];
	}

	return sMapping;
}

// ----------------------------------------------------------------------------

void
IOSActivityPluginUtils::PushEvent( lua_State *L, const char *luaActivityType, BOOL completed, NSArray *returnedItems, NSError *activityError )
{
	Corona::Lua::NewEvent( L, kEventName );
	
	lua_pushstring( L, IOSActivityNativePopupProvider::kPopupValue );
	lua_setfield( L, -2, CoronaEventTypeKey() );

	lua_pushstring( L, luaActivityType );
	lua_setfield( L, -2, "activity" );

	const char kCancelledAction[] = "cancelled";
	const char kSentAction[] = "sent";
	lua_pushstring( L, ( completed ? kSentAction : kCancelledAction ) );
	lua_setfield( L, -2, "action" );
}

NSString *
IOSActivityPluginUtils::ToFilePath( lua_State *L, int index )
{
	// pathService->PushPath( L, -1 );
	CoronaLibraryCallFunction( L, "system", "pathForTable", "t>s", CoronaLuaNormalize( L, index ) );
	NSString *result = ToNSString( L, -1 );
	lua_pop( L, 1 );

	return result;
}

UIImage *
IOSActivityPluginUtils::ToUIImage( lua_State *L, int index )
{
	UIImage *result = nil;

	NSString *path = ToFilePath( L, index );
	if ( path )
	{
		result = [UIImage imageWithContentsOfFile:path];
	}

	return result;
}

NSString *
IOSActivityPluginUtils::ToNSString( lua_State *L, int index )
{
	NSString *result = nil;

	const char *str = lua_tostring( L, index );
	if ( str )
	{
		result = [NSString stringWithUTF8String:str];
	}

	return result;
}

NSURL *
IOSActivityPluginUtils::ToNSURL( lua_State *L, int index )
{
	NSURL *result = nil;

	NSString *path = ToNSString( L, index );
	if ( path )
	{
		result = [NSURL URLWithString:path];
	}

	return result;
}

NSString *
IOSActivityPluginUtils::ToUIActivityType( lua_State *L, int index )
{
	NSString *result = nil;

	NSString *activityName = ToNSString( L, index );
	if ( activityName )
	{
		result = [UIActivityForLuaStringMapping() valueForKey:activityName];

		// If this is not a built-in activities, then it's a custom activity
		// so just use the string value itself
		if ( ! result )
		{	
			result = activityName;
		}
	}

	return result;
}

const char *
IOSActivityPluginUtils::ToLuaActivityType( NSString *uiKitActivityType )
{
	return [[LuaStringForUIActivityMapping() valueForKey:uiKitActivityType] UTF8String];
}

NSArray *
IOSActivityPluginUtils::ToUIActivityTypeArray( lua_State *L, int index, const char *errorLabel )
{
	NSMutableArray *result = nil;

	index = CoronaLuaNormalize( L, index );

	if ( lua_istable( L, index ) )
	{
		result = [NSMutableArray array];

		// Lua is 1-based
		for ( int i = 1, iLen = (int)lua_objlen( L, index ); i <= iLen; i++ )
		{
			lua_rawgeti( L, index, i );
			NSString *activityType = IOSActivityPluginUtils::ToUIActivityType( L, -1 );
			if ( activityType )
			{
				[result addObject:activityType];
			}
			else
			{
				if ( errorLabel )
				{
					CORONA_LOG_WARNING( "[%s] Item at index (%d) was not a valid activity string.", errorLabel, i );
				}
			}
			lua_pop( L, 1 ); // pop
		}
	}

	return result;
}

id
IOSActivityPluginUtils::ToItemValue( lua_State *L, int index, const char *itemType )
{
	id value = nil;

	lua_getfield( L, index, "value" ); // push value
	if ( 0 == strcmp( itemType, "string" ) )
	{
		value = ToNSString( L, -1 );
	}
	else if ( 0 == strcmp( itemType, "url" ) )
	{
		value = ToNSURL( L, -1 );
	}
	else if ( 0 == strcmp( itemType, "image" ) )
	{
		value = ToUIImage( L, -1 );
	}
	// else if ( 0 == strcmp( itemType, "color" ) )
	// {
	// 	value = ToUIColor( L, -1 );
	// }
	// else if ( 0 == strcmp( itemType, "dictionary" ) )
	// {
	// 	value = CoronaLuaCreateDictionary( L, -1 );
	// }
	lua_pop( L, 1 ); // pop value
	
	return value;
}

NSArray *
IOSActivityPluginUtils::ToItemArray( lua_State *L, int index, const char *errorLabel )
{
	NSMutableArray *result = nil;

	index = CoronaLuaNormalize( L, index );

	if ( lua_istable( L, index ) )
	{
		result = [NSMutableArray array];

		// Lua is 1-based
		for ( int i = 1, iLen = (int)lua_objlen( L, index ); i <= iLen; i++ )
		{
			lua_rawgeti( L, index, i );
			if ( lua_istable( L, -1 ) )
			{
				int itemIndex = lua_gettop( L );

				lua_getfield( L, itemIndex, "type" );
				const char *itemType = lua_tostring( L, -1 );
				if ( itemType )
				{
					id value = IOSActivityPluginUtils::ToItemValue( L, itemIndex, itemType );
					if ( value )
					{
						[result addObject:value];
					}
					else if ( errorLabel )
					{
						CORONA_LOG_WARNING( "[%s] The item type(%s) at index(%d) is not supported.", errorLabel, itemType, i );
					}
				}
				else if ( errorLabel )
				{
					CORONA_LOG_WARNING( "[%s] The item at index(%d) is missing the 'type' property.", errorLabel, i );
				}
				lua_pop( L, 1 ); // pop type
			}
			else if ( errorLabel )
			{
				CORONA_LOG_WARNING( "[%s] Cannot process item at index (%d). It's a %s instead of a table.", errorLabel, i, lua_typename( L, lua_type( L, -1 ) ) );
			}
			lua_pop( L, 1 ); // pop item element
		}
	}

	return result;
}

// ----------------------------------------------------------------------------

} // namespace Corona

// ----------------------------------------------------------------------------
