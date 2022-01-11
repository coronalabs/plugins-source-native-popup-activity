//
//  IOSActivityNativePopupProvider.mm
//
//  Copyright (c) 2015 CoronaLabs Inc. All rights reserved.
//

#include "IOSActivityNativePopupProvider+Private.h"

#import <UIKit/UIKit.h>
#import "CoronaRuntime.h"

#include "CoronaAssert.h"
#include "CoronaEvent.h"
#include "CoronaLog.h"
#include "CoronaLuaIOS.h"
#include "CoronaLibrary.h"
#include "IOSActivityPluginUtils.h"

// ----------------------------------------------------------------------------

namespace Corona
{

// ----------------------------------------------------------------------------

const char IOSActivityNativePopupProvider::kPopupValue[] = "activity";

static const char kMetatableName[] = __FILE__; // Globally unique value
static const char *kEventName = CoronaEventPopupName();

// ----------------------------------------------------------------------------

int
IOSActivityNativePopupProvider::Open( lua_State *L )
{
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
	void *platformContext = CoronaLuaGetContext( L );

	const char *name = lua_tostring( L, 1 ); CORONA_ASSERT( 0 == strcmp( kPopupValue, name ) );
	int result = CoronaLibraryProviderNew( L, "native.popup", name, "com.coronalabs" );

	if ( result > 0 )
	{
		int libIndex = lua_gettop( L );

		Self *library = new Self;

		if ( library->Initialize( platformContext ) )
		{
			static const luaL_Reg kFunctions[] =
			{
				{ "canShowPopup", canShowPopup },
				{ "showPopup", showPopup },

				{ NULL, NULL }
			};

			// Register functions as closures, giving each access to the
			// 'library' instance via ToLibrary()
			{
				lua_pushvalue( L, libIndex ); // push library
				CoronaLuaPushUserdata( L, library, kMetatableName ); // push library ptr
				luaL_openlib( L, NULL, kFunctions, 1 );
				lua_pop( L, 1 ); // pop library
			}
		}
	}

	return result;
}

int
IOSActivityNativePopupProvider::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
	delete library;
	return 0;
}

IOSActivityNativePopupProvider::Self *
IOSActivityNativePopupProvider::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

// ----------------------------------------------------------------------------

IOSActivityNativePopupProvider::IOSActivityNativePopupProvider()
:	fAppViewController( nil )
{
}

bool
IOSActivityNativePopupProvider::Initialize( void *platformContext )
{
	bool result = ( ! fAppViewController );

	if ( result )
	{
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)platformContext;
		fAppViewController = runtime.appViewController; // TODO: Should we retain?
	}

	return result;
}

// ----------------------------------------------------------------------------

// native.canShowPopup( "activity" [, activityName] )
int
IOSActivityNativePopupProvider::canShowPopup( lua_State *L )
{
	bool result = true; // default

	if ( lua_type( L, 2 ) == LUA_TSTRING )
	{
		NSString *activityType = IOSActivityPluginUtils::ToUIActivityType( L, 2 );
		result = ( nil != activityType );
	}

	lua_pushboolean( L, result );
	return 1;
}

// native.showPopup( "activity", options )
int
IOSActivityNativePopupProvider::showPopup( lua_State *L )
{
	using namespace Corona;

	// Library instance
	Self *context = ToLibrary( L );
	
	if ( context )
	{
		Self& library = * context;

		// Retrieve parameters from the "options" table
		if ( lua_istable( L, 2 ) )
		{
			// options.items (required)
			lua_getfield( L, -1, "items" );
			NSArray *activityItems = IOSActivityPluginUtils::ToItemArray( L, -1, "options.items" );
			lua_pop( L, 1 );

			// options.excludedActivities (optional)
			lua_getfield( L, -1, "excludedActivities" );
			NSArray *excludedActivities = IOSActivityPluginUtils::ToUIActivityTypeArray( L, -1, "options.excludedActivities" );
			lua_pop( L, 1 );

			// options.listener (optional)
			Lua::Ref listenerRef = NULL;
			lua_getfield( L, -1, "listener" );
			if ( Lua::IsListener( L, -1, kEventName ) )
			{
				// Create native reference to listener
				listenerRef = Lua::NewRef( L, -1 );
			}
			lua_pop( L, 1 );

			UIActivityViewControllerCompletionWithItemsHandler handler = nil;
			
			// Initialize handler if a listener was set
			if ( listenerRef )
			{
				handler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
				{
					const char *luaActivityType = IOSActivityPluginUtils::ToLuaActivityType( activityType );

					// Create event and invoke listener
					IOSActivityPluginUtils::PushEvent( L, luaActivityType, completed, returnedItems, activityError ); // push event
					Lua::DispatchEvent( L, listenerRef, 0 );

					// Free native reference to listener
					if ( !activityType || completed ) {
						Lua::DeleteRef( L, listenerRef );
					}
				};
			}

			// Intended to make it easy to pass origin=button.contentBounds
			// (uses modified code from `media.selectPhoto()` in core engine
			UIPopoverArrowDirection direction = UIPopoverArrowDirectionAny;
			float xmin = NAN;
			float ymin = NAN;
			float xmax = NAN;
			float ymax = NAN;

			
			lua_getfield( L, -1, "origin" );
			if ( lua_type( L, -1) == LUA_TTABLE )
			{
				lua_getfield( L, -1, "xMin" );
				if ( lua_type( L, -1) == LUA_TNUMBER )
				{
					xmin = lua_tonumber( L, -1 );
				}
				lua_pop( L, 1 );
				
				lua_getfield( L, -1, "yMin" );
				if ( lua_type( L, -1) == LUA_TNUMBER )
				{
					ymin = lua_tonumber( L, -1 );
				}
				lua_pop( L, 1 );
				
				lua_getfield( L, -1, "xMax" );
				if ( lua_type( L, -1) == LUA_TNUMBER )
				{
					xmax = lua_tonumber( L, -1 );
				}
				lua_pop( L, 1 );
				
				lua_getfield( L, -1, "yMax" );
				if ( lua_type( L, -1) == LUA_TNUMBER )
				{
					ymax = lua_tonumber( L, -1 );
				}
				lua_pop( L, 1 );
			}
			lua_pop( L, 1 );
			
			lua_getfield( L, -1, "permittedArrowDirections" );
			if ( lua_type( L, -1) == LUA_TNUMBER)
			{
				// Support backdoor integer in case users need to specify the undocumented value '0' for no arrow
				direction = lua_tonumber( L, -1 );
			}
			else if ( lua_type( L, -1) == LUA_TSTRING )
			{
				if ( 0 == strcmp( "any", lua_tostring( L, -1 ) ) )
				{
					direction = UIPopoverArrowDirectionAny;
				}
				else if( 0 == strcmp( "up", lua_tostring( L, -1 ) ) )
				{
					direction = UIPopoverArrowDirectionUp;
				}
				else if( 0 == strcmp( "down", lua_tostring( L, -1 ) ) )
				{
					direction = UIPopoverArrowDirectionDown;
				}
				else if( 0 == strcmp( "left", lua_tostring( L, -1 ) ) )
				{
					direction = UIPopoverArrowDirectionLeft;
				}
				else if( 0 == strcmp( "right", lua_tostring( L, -1 ) ) )
				{
					direction = UIPopoverArrowDirectionRight;
				}
			}
			else if ( lua_type( L, -1) == LUA_TTABLE )
			{
				int max = lua_objlen( L, -1 );
				// Make sure the table isn't empty.
				if ( max > 0 )
				{
					// We need to clear the the 'Any' direction set above.
					direction = 0;
					// Assumes an array of strings
					for ( int i = 1; i <= max; i++ )
					{
						lua_rawgeti( L, -1, i );
						
						if ( 0 == strcmp( "any", lua_tostring( L, -1 ) ) )
						{
							direction |= UIPopoverArrowDirectionAny;
						}
						else if( 0 == strcmp( "up", lua_tostring( L, -1 ) ) )
						{
							direction |= UIPopoverArrowDirectionUp;
						}
						else if( 0 == strcmp( "down", lua_tostring( L, -1 ) ) )
						{
							direction |= UIPopoverArrowDirectionDown;
						}
						else if( 0 == strcmp( "left", lua_tostring( L, -1 ) ) )
						{
							direction |= UIPopoverArrowDirectionLeft;
						}
						else if( 0 == strcmp( "right", lua_tostring( L, -1 ) ) )
						{
							direction |= UIPopoverArrowDirectionRight;
						}
						
						lua_pop( L, 1 );
					}
				}
			}
			
			library.PresentController( L, activityItems, excludedActivities, handler, xmin, ymin, xmax, ymax, direction );
		}
		else
		{
			luaL_error( L, "native.showPopup( %s, options ). The 2nd 'options' param is required", kPopupValue );
		}
	}

	return 0;
}

void
IOSActivityNativePopupProvider::PresentController(
	lua_State *L,
	NSArray *items,
	NSArray *excludedActivities,
	UIActivityViewControllerCompletionWithItemsHandler handler,
	float xmin, float ymin, float xmax, float ymax,
	unsigned int direction )
{
	UIActivityViewController *controller = [[[UIActivityViewController alloc] 
											initWithActivityItems:items applicationActivities:nil]autorelease];
	controller.excludedActivityTypes = excludedActivities;

	if ( handler )
	{
		if ( [controller respondsToSelector:@selector(completionWithItemsHandler)] )
		{
			// iOS 8 and later
			controller.completionWithItemsHandler = handler;			
		}
		else
		{
			// Handle backward compatibility for iOS 6
			controller.completionHandler = ^(NSString *activityType, BOOL completed)
			{
				handler( activityType, completed, nil, nil );
			};
		}
	}
	
	if( UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone )
	{
		[GetAppViewController() presentViewController:controller animated:YES completion:nil];
	}
	else
	{
		UIView* view = [GetAppViewController() view];
		UIPopoverController *popup = [[[UIPopoverController alloc] initWithContentViewController:controller] autorelease];

		CGRect popover;
		if ( xmin != xmin || ymin != ymin || xmax !=xmax || ymax != ymax )
		{
			//default to the middle-botom
			popover.origin.x = view.frame.size.width*0.5;
			popover.origin.y = view.frame.size.height;
			popover.size.width = 0;
			popover.size.height = 0;
		}
		else
		{
			//transform lua coordinates to device
			id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
			CGPoint min = [runtime coronaPointToUIKitPoint:CGPointMake(xmin, ymin)];
			CGPoint max = [runtime coronaPointToUIKitPoint:CGPointMake(xmax, ymax)];
			popover = CGRectMake( min.x, min.y, max.x-min.x, max.y-min.y );
		}
		
		if ( 0 == direction )
		{
			direction = UIPopoverArrowDirectionAny;
		}
		
		[popup presentPopoverFromRect:popover inView:view permittedArrowDirections:direction animated:YES];
	}
	
}

// ----------------------------------------------------------------------------

} // namespace Corona

// ----------------------------------------------------------------------------

CORONA_EXPORT
int luaopen_CoronaProvider_native_popup_activity( lua_State *L )
{
	return Corona::IOSActivityNativePopupProvider::Open( L );
}

// ----------------------------------------------------------------------------
