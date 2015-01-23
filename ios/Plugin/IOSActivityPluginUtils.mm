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
			@"postToFacebook" : UIActivityTypePostToFacebook,
			@"postToTwitter" : UIActivityTypePostToTwitter,
			@"postToWeibo" : UIActivityTypePostToWeibo,
			@"message" : UIActivityTypeMessage,
			@"mail" : UIActivityTypeMail,
			@"print" : UIActivityTypePrint,
			@"copyToPasteboard" : UIActivityTypeCopyToPasteboard,
			@"assignToContact" : UIActivityTypeAssignToContact,
			@"saveToCameraRoll" : UIActivityTypeSaveToCameraRoll,
		};

		NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithDictionary:mapping_v6];

		if ( nil == UIActivityTypeAddToReadingList )
		{
			// Activity types introduced in iOS 7.0
			NSDictionary *mapping_v7 = @{
				@"addToReadingList" : UIActivityTypeAddToReadingList,
				@"postToFlickr" : UIActivityTypePostToFlickr,
				@"postToVimeo" : UIActivityTypePostToVimeo,
				@"postToTencentWeibo" : UIActivityTypePostToTencentWeibo,
				@"airDrop" : UIActivityTypeAirDrop,
			};

			[mapping addEntriesFromDictionary:mapping_v7];
		}

		sMapping = mapping;
	}

	return sMapping;
}

// ----------------------------------------------------------------------------

void
IOSActivityPluginUtils::PushEvent( lua_State *L, NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError )
{
	Corona::Lua::NewEvent( L, kEventName );
	
	lua_pushstring( L, IOSActivityNativePopupProvider::kPopupValue );
	lua_setfield( L, -2, CoronaEventTypeKey() );

	lua_pushstring( L, [activityType UTF8String] );
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
//	else if ( 0 == strcmp( itemType, "color" ) )
//	{
//		value = ToUIColor( L, -1 );
//	}
	else if ( 0 == strcmp( itemType, "dictionary" ) )
	{
		value = CoronaLuaCreateDictionary( L, -1 );
	}
	lua_pop( L, 1 ); // pop value
	
	return value;
}


// ----------------------------------------------------------------------------

} // namespace Corona

// ----------------------------------------------------------------------------
