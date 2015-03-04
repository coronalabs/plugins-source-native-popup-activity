//
//  IOSActivityNativePopupProvider+Private.h
//
//  Copyright (c) 2015 CoronaLabs Inc. All rights reserved.
//

#ifndef _IOSActivityNativePopupProvider_Private_H__
#define _IOSActivityNativePopupProvider_Private_H__

#include "IOSActivityNativePopupProvider.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIActivityViewController.h>

#include "CoronaLua.h"

// ----------------------------------------------------------------------------

@class UIViewController;

namespace Corona
{

// ----------------------------------------------------------------------------

class IOSActivityNativePopupProvider
{
	public:
		typedef IOSActivityNativePopupProvider Self;

	public:
		static const char kPopupValue[];

	public:
		static int Open( lua_State *L );
		static int Finalizer( lua_State *L );
		static Self *ToLibrary( lua_State *L );

	protected:
		IOSActivityNativePopupProvider();
		bool Initialize( void *platformContext );

	public:
		UIViewController* GetAppViewController() const { return fAppViewController; }

	public:
		static int canShowPopup( lua_State *L );
		static int showPopup( lua_State *L );

	protected:
		void PresentController(
			lua_State *L,
			NSArray *items,
			NSArray *excludedActivities,
			UIActivityViewControllerCompletionWithItemsHandler handler,
				float xmin, float ymin, float xmax, float ymax,
				unsigned int direction);

	private:
		UIViewController *fAppViewController;
};

// ----------------------------------------------------------------------------

} // namespace Corona

// ----------------------------------------------------------------------------

#endif // _IOSActivityNativePopupProvider_Private_H__
