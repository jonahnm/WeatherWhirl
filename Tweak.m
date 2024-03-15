#include <CoreFoundation/CFCGTypes.h>
#include <CoreGraphics/CGGeometry.h>
#include <Foundation/NSObjCRuntime.h>
#include <UIKit/UIImageView.h>
#include <UIKit/UIScreen.h>
#include <UIKit/UIViewController.h>
#include <substrate.h>
#include <UIKit/UIKit.h>
#include "WeatherHandler.h"
@interface PBUIPosterWallpaperRemoteViewController: UIViewController 
@end
static void (*ogviewdidload)(PBUIPosterWallpaperRemoteViewController *self, SEL _cmd);
static void viewDidLoadHook(PBUIPosterWallpaperRemoteViewController *self, SEL _cmd) {
    ogviewdidload(self,_cmd);
    UIView *view = self.view;
    UIImage *img = UIImageForCurrentWeather();
    if(img == nil) {
        return;
    }
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    [view addSubview:imgView];
    [view bringSubviewToFront:imgView];
}

__attribute__((constructor)) static void init() {
    MSHookMessageEx(NSClassFromString(@"PBUIPosterWallpaperRemoteViewController"), @selector(viewDidLoad), (IMP)&viewDidLoadHook, (IMP *)&ogviewdidload);   
}