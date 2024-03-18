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
#include "CloudView.h"
#include "FLAnimatedImage/FLAnimatedImage.h"
#include "HomeScreenView.h"
#include "WeatherHandler.h"
@interface SBHomeScreenViewController : UIViewController
@end
static void (*ogviewdidload)(SBHomeScreenViewController *self, SEL _cmd);
static void viewDidLoadHook(SBHomeScreenViewController *self, SEL _cmd) {
   ogviewdidload(self,_cmd);
   NSLog(@"SBHomeScreenViewController frame width: %f height: %f",self.view.frame.size.width,self.view.frame.size.height);
   HomeScreenView *weatherView = [[HomeScreenView alloc] initWithFrame:self.view.frame];
   weatherView.cloudView = [[CloudView alloc] init];
   [self.view addSubview:weatherView];
   [self.view sendSubviewToBack:weatherView];
   FLAnimatedImage *animatedImg = nil;
   int weatherID = 0;
   UIImage *unscaledImg = UIImageForCurrentWeather(&animatedImg,&weatherID);
   if(unscaledImg == nil) {
    NSLog(@"Failed to get current UIImage for weather.");
    return;
   }
   if(weatherID != 0) {
     [weatherView placeClouds:weatherID];
   }
   if(animatedImg != nil) {
        [weatherView setAnimationWithGif:animatedImg :TopLeftCorner];
   }
   if(![weatherView setBackgroundWithImage:unscaledImg]) {
        NSLog(@"Failed to set the background for current weather!");
        return;
   }
   //self.referenceView = weatherView;
}

__attribute__((constructor)) static void init() {
    MSHookMessageEx(NSClassFromString(@"SBHomeScreenViewController"), @selector(viewDidLoad), (IMP)&viewDidLoadHook, (IMP *)&ogviewdidload);
}