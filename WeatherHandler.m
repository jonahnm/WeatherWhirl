#include "WeatherHandler.h"
#include "FLAnimatedImage/FLAnimatedImage.h"
#include "FLAnimatedImage/FLAnimatedImageView.h"
#include "Preferences.h"
#include "libroot/libroot.h"
#include <CoreFoundation/CFCGTypes.h>
#import <CoreFoundation/CoreFoundation.h>
#include <UIKit/NSStringDrawing.h>
#include <objc/objc.h>
#include <Foundation/NSData.h>
#include <_xlocale.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDate.h>
#include <UIKit/UIGraphics.h>
#include <CoreGraphics/CGGeometry.h>
#include <UIKit/UIKit.h>
#include <Foundation/NSBundle.h>
#include <CoreLocation/CoreLocation.h>
#include <CoreLocation/CLLocation.h>
#include <objc/runtime.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSFileManager.h>
#include <time.h>
#include <MobileGestalt/MobileGestalt.h>
#include <Foundation/NSObjCRuntime.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSJSONSerialization.h>
#include <Foundation/NSString.h>
#include <Foundation/NSURLSession.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
@import FLAnimatedImage;
@implementation UIImage (Resize)
-(UIImage *)resizedImageWithBounds:(CGSize)bounds {
return self;
}
@end
@implementation Storage
    static CLLocation *_location;
    +(CLLocation *)location {
    return _location;
    }
    +(void)setLocation:(CLLocation *)location {
    _location = location;
    }
@end
static UIImage *cachedImage = nil;
static struct tm *cachedTime = NULL;

NSArray *fetchForecast(struct tm *gmcurtime,NSURL *path) {
    CLLocation *location = Storage.location;
   // NSLog(@"%@",location.description);
    CFStringRef deviceid = MGGetStringAnswer(kMGUniqueDeviceID);
    NSString *deviceid_ = (__bridge NSString *)deviceid;
    NSString *urlstr = [NSString stringWithFormat:@"http://sorasstuff.me/weather?lat=%F&lon=%F&uuid=%@",location.coordinate.latitude,location.coordinate.longitude,deviceid_];
    NSURL *url = [NSURL URLWithString:urlstr];
    __block NSArray *out = nil;
    __block bool shouldret = false;
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            shouldret = true;
            return;
        }
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str isEqualToString:@"Malformed Request"] || [str isEqualToString:@"Not authed"] || [str isEqualToString:@"Cannot make more than 2 requests a day!"]) {
            shouldret = true;
            return;
        }
        NSError *err;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err) {
            NSLog(@"%@",err);
            shouldret = true;
            return;
        }
        NSLog(@"%@",results);
        out = results[@"hourly"];
        shouldret = true;
    }];
    [downloadTask resume];
    while(!shouldret) {};
    if(out == nil) {
        return nil;
    }
    @autoreleasepool {
    NSDictionary *toWrite = @{
        @"forDay": @(gmcurtime->tm_yday),
        @"hourly": out,
    };
    NSError *err;
    NSData *toactuallywrite = [NSJSONSerialization dataWithJSONObject:toWrite options:NSJSONWritingPrettyPrinted error:&err];
    if(err) {
        NSLog(@"Failed to write forecast plist: %@",err);
        return nil;
    }
    [toactuallywrite writeToURL:path atomically:YES];
    free(gmcurtime);
    }
    return out;
}
NSArray *getForecast(void) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    #if TARGET_IPHONE_SIMULATOR
    NSString *path = @"/Library/Application Support/WeatherWhirl/Forecast.plist";
    #else
    NSString *path = ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/Forecast.json");
    #endif
    NSURL *url = [NSURL fileURLWithPath:path];
    struct tm *gmcurtime = NULL; 
    time_t temptime = time(NULL);
    gmcurtime = gmtime(&temptime);
    if(![fileManager fileExistsAtPath:path]) {
        return fetchForecast(gmcurtime, url);
    } else {
        NSError *err;
        NSDictionary *contents = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:&err];
        if(err) {
            NSLog(@"Something went wrong reading forecast plist: %@",err);
            return nil;
        }
        NSNumber *wasForDay = contents[@"forDay"];
        if([wasForDay intValue] != gmcurtime->tm_yday) {
            NSError *err;
            [fileManager removeItemAtPath:path error:&err];
            if(err) {
                NSLog(@"%@",err);
                return nil;
            }
            return fetchForecast(gmcurtime, url);
        } else {
        return contents[@"hourly"];
        }
    }
}
int getIDOfCurrentWeather(NSString **outName) {
    NSArray *forecast = getForecast();
    if(forecast == nil) {
        NSLog(@"I appear to have encountered an error getting the forecast for today... Returning!");
        return 0;
    }
    time_t curTime = time(NULL);
    struct tm *curgmtime = localtime(&curTime);
    for(NSDictionary *hour in forecast) {
        NSNumber *NSdt = hour[@"dt"];
        time_t dt = (time_t)[NSdt longValue];
        struct tm *dgmt = localtime(&dt);
        if(dgmt->tm_hour != curgmtime->tm_hour || dgmt->tm_wday != curgmtime->tm_wday) {
            free(dgmt);
            continue;
        }
        NSLog(@"Showing for hour: %i",dgmt->tm_hour);
        *outName = hour[@"weather"][0][@"description"];
        return [((NSNumber *)(hour[@"weather"][0][@"id"])) intValue];
    }
    return 0;
}
UIImage *UIImageForCurrentWeather(FLAnimatedImage **animatedImageOut,int *idOut) {
    time_t curtime = time(NULL);
    if(cachedImage == nil || (cachedTime != NULL && cachedTime->tm_hour != localtime(&curtime)->tm_hour)) {
    int id = 0;
    NSString *weatherName = nil;
    if(!WWPreferences.overrideNext) {
    id = getIDOfCurrentWeather(&weatherName);
    } else {
        NSString *override = WWPreferences.override;
        if([override isEqualToString:@"light rain"]) {
            id = 500;
        }
        if([override isEqualToString:@"clear sky"]) {
            id = 800;
        }
        if([override isEqualToString:@"few clouds"]) {
            id = 801;
        }
        if([override isEqualToString:@"scattered clouds"]) {
            id = 802;
        }
        if([override isEqualToString:@"broken clouds"]) {
            id = 803;
        }
        if([override isEqualToString:@"overcast clouds"]) {
            id = 804;
        }
        if ([override isEqualToString:@"moderate rain"]) {
            id = 501;
        }
        if ([override isEqualToString:@"heavy intensity rain"]) {
            id = 502;
        }
        [WWPreferences setOverrideNext:NO];
    }
    *idOut = id;
    NSString *filePath = @"";
    NSString *animpath = @"";
    NSLog(@"Current Weather ID: %d",id);
    switch(id) {
        case 800:
        animpath = ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/sunAnim.gif");
        case 801:
        case 802:
        case 803:
        case 804:
        #if TARGET_IPHONE_SIMULATOR
        filePath = @"/Library/Application Support/WeatherWhirl/clearskies.jpg";
        #else
        filePath = ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/clearskies.jpg");
        #endif
        NSLog(@"%@",filePath);
        break;
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
        case 511:
        case 520:
        case 521:
        case 522:
        case 531:
        filePath = ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/grey.jpg");
        break;
    }
    NSLog(@"%@",weatherName);
    UIImage *background = nil;
    if(weatherName != nil) {
        background = [WWPreferences customBackground:weatherName];
    } else {
        background = [WWPreferences customBackground:[WWPreferences override]];
    }
    NSLog(@"%@",filePath);
    if([filePath isEqualToString:@""]) {
        return nil;
    }
    bool shoulddoAnim = true;
    if([animpath isEqualToString:@""]) {
        shoulddoAnim = false;
    }
    /*
    if(![splitFolder isEqualToString:@""]) {
        NSError *err;
        NSArray *dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:splitFolder error:&err];
        if(!err) {
            NSMutableArray<UIImage *> *splitImages = [[NSMutableArray alloc] init];
            for(NSString *path in dir) {
                [splitImages addObject:[UIImage imageWithContentsOfFile:path]];
            }
        } else {
            NSLog(@"%@",err);
        }
    }
    */
    if(background == nil) {
        background = [UIImage imageWithContentsOfFile:filePath];
    }
    cachedImage = background;
    AntiARCRetain(cachedImage);
    cachedTime = localtime(&curtime);
    if(shoulddoAnim && animatedImageOut != NULL) {
        NSData *gifData = [NSData dataWithContentsOfFile:animpath];
        *animatedImageOut = [FLAnimatedImage animatedImageWithGIFData:gifData];
    }
    return cachedImage;
    } else {
        return cachedImage;
    }
}