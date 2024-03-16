#include <CoreFoundation/CFCGTypes.h>
#include <CoreGraphics/CGGeometry.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSError.h>
#include <Foundation/NSObjCRuntime.h>
#include <UIKit/UIImageView.h>
#include <UIKit/UIScreen.h>
#include <UIKit/UIView.h>
#include <UIKit/UIViewController.h>
#include <objc/NSObjCRuntime.h>
#include <objc/NSObject.h>
#include <objc/runtime.h>
#include <substrate.h>
#include <UIKit/UIKit.h>
#include "HomeScreenView.h"
#include "WeatherHandler.h"
@interface SBHomeScreenViewController : UIViewController
- (id)homeScreenView;
//@property HomeScreenView *referenceView;
@end
static void (*ogviewdidload)(SBHomeScreenViewController *self, SEL _cmd);
static void viewDidLoadHook(SBHomeScreenViewController *self, SEL _cmd) {
   ogviewdidload(self,_cmd);
   HomeScreenView *weatherView = [[HomeScreenView alloc] init];
   [self.view addSubview:weatherView];
   [self.view sendSubviewToBack:weatherView];
   //self.referenceView = weatherView;
}

__attribute__((constructor)) static void init() {
    MSHookMessageEx(NSClassFromString(@"SBHomeScreenViewController"), @selector(viewDidLoad), (IMP)&viewDidLoadHook, (IMP *)&ogviewdidload);
    /*
    char *HomeScreenViewEncoding = @encode(HomeScreenView);
    NSUInteger homeScreenViewSize,HomeScreenViewAlign;
    NSGetSizeAndAlignment(HomeScreenViewEncoding, &homeScreenViewSize, &HomeScreenViewAlign);
    class_addIvar(NSClassFromString(@"SBHomeScreenViewController"), "_referenceView",homeScreenViewSize, HomeScreenViewAlign, HomeScreenViewEncoding);
    objc_property_attribute_t type = {"T","@\"HomeScreenView\""};
    objc_property_attribute_t ownership = {"C",""};
    objc_property_attribute_t backingivar = {"V","_referenceView"};
    objc_property_attribute_t attrs[] = {type,ownership,backingivar};
    class_addProperty(NSClassFromString(@"SBHomeScreenViewController"), "referenceView", attrs, 3);
    */
}