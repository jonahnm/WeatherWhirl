#include <CoreFoundation/CFCGTypes.h>
#include <CoreGraphics/CGGeometry.h>
#include <Foundation/Foundation.h>
#include <CoreLocation/CoreLocation.h>
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
#include "Preferences.h"
#include "WeatherHandler.h"
#include "rootless.h"
@interface SBHomeScreenViewController : UIViewController
@end
%hook SBHomeScreenViewController
- (void)viewDidAppear:(BOOL)animated {
   %orig(animated);
   //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
   NSLog(@"SBHomeScreenViewController frame width: %f height: %f",self.view.frame.size.width,self.view.frame.size.height);
   HomeScreenView *weatherView = [[HomeScreenView alloc] initWithFrame:self.view.frame];
   weatherView.preferredFramesPerSecond = 25;
   weatherView.scene = [HomeScreen scene];
   Storage.sceneView = weatherView;
   HomeScreen *scene = (HomeScreen *)weatherView.scene;
   scene.cloudView = [Clouds node];
  // ((CloudView*)weatherView.cloudView).backgroundColor = UIColor.clearColor;
   weatherView.backgroundColor = UIColor.clearColor;
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
     [scene placeClouds:weatherID];
   }
   if(animatedImg != nil) {
        [scene setAnimationWithGif:animatedImg :TopLeftCorner];
   }
   if(![scene setBackgroundWithImage:unscaledImg]) {
        NSLog(@"Failed to set the background for current weather!");
        return;
   }
   //});
   //self.referenceView = weatherView;
}
%end
%hook TheLocationProvider
     %property (nonatomic) CLLocation *ourlocation;
     -(instancetype)init {
     self = %orig;
     Storage.location = ((CLLocationManager *)[self valueForKey:@"_locationManager"]).location;
     return self;
     }
%end
%hook SBIconImageView
     -(void)setFrame:(CGRect)frame {
          %orig(frame);
          NSLog(@"Hello");
          if(Storage.sceneView == nil) {
          [Storage.queuedIcons addObject:[[Icon alloc] initWithIconView:(UIImageView *)self]];
          } else {
               [[Storage.sceneView.scene rootNode] addChildNode:[[Icon alloc] initWithIconView:(UIImageView *)self]];
          }
     }
%end
%ctor {
    NSString *path = @"/var/mobile/Library/Preferences/com.sora.weatherwhirl.plist";
    
    [WWPreferences loadPrefsWithURL:[NSURL fileURLWithPath:path]];
    if(!WWPreferences.isEnabledTweak) {
          [WWPreferences freeMe];
          return;
    }
    id class = objc_getClass("DNDSLocationLifetimeMonitor");
    if(@available(iOS 15, *)) {
          class = objc_getClass("UNSLocationMonitor");
    }
    %init(TheLocationProvider=class);
}