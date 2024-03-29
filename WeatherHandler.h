#ifndef WEATHERHANDLER_H
#define WEATHERHANDLER_H
#include "FLAnimatedImage/FLAnimatedImage.h"
#include <CoreFoundation/CoreFoundation.h>
#include <CoreLocation/CLLocation.h>
#define AntiARCRetain(...) void *retainedThing = (__bridge_retained void *)__VA_ARGS__; retainedThing = retainedThing
#define AntiARCRelease(...) void *retainedThing = (__bridge void *) __VA_ARGS__; id unretainedThing = (__bridge_transfer id)retainedThing; unretainedThing = nil
#import <UIKit/UIImage.h>
#import <CoreLocation/CLLocationManager.h>
@import FLAnimatedImage;
UIImage *UIImageForCurrentWeather(FLAnimatedImage **animatedImageOut,int *idOut);
@interface CLLocationManager (Private)
+ (void)setAuthorizationStatus:(BOOL)arg1 forBundleIdentifier:(NSString *)arg2;
+ (int)_authorizationStatusForBundleIdentifier:(NSString *)id bundle:(NSString *)bundle;
+ (BOOL)convertAuthStatusToBool:(int)status;
+ (void)setAuthorizationStatusByType:(int)arg1 forBundleIdentifier:(id)arg2;
- (void)requestWhenInUseAuthorizationWithPrompt;
@end
@interface Storage : NSObject
    @property (class) CLLocation *location;
@end
@interface UIImage (Resize)
-(UIImage *)resizedImageWithBounds:(CGSize)bounds;
@end
#endif