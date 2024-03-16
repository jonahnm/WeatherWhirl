#include "WeatherHandler.h"
#include "libroot/libroot.h"
#import <CoreFoundation/CoreFoundation.h>
#include <Foundation/NSBundle.h>
#include <CoreLocation/CoreLocation.h>
#include <CoreLocation/CLLocation.h>
#include <objc/runtime.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSFileManager.h>
#include <time.h>
#include <Foundation/NSObjCRuntime.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSJSONSerialization.h>
#include <Foundation/NSString.h>
#include <Foundation/NSURLSession.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
static UIImage *cachedImage = nil;
static struct tm *cachedTime = NULL;
NSArray *fetchForecast(struct tm *gmcurtime,NSString *path) {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [CLLocationManager setAuthorizationStatus:YES forBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    [locationManager startUpdatingLocation];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    NSString *urlstr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/3.0/onecall?lat=%f&lon=%f&appid=4cfd64f823763c23be0eb25c78eb5183",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlstr];
    [locationManager stopUpdatingLocation];
    __block NSArray *out = nil;
    __block bool shouldret = false;
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            shouldret = true;
            return;
        }
        NSError *err;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err) {
            NSLog(@"%@",err.description);
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
    NSDictionary *toWrite = @{
        @"forDay": @(gmcurtime->tm_yday),
        @"hourly": out,
    };
    [toWrite writeToFile:path atomically:YES];
    free(gmcurtime);
    return out;
}
NSArray *getForecast(void) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    #if TARGET_IPHONE_SIMULATOR
    NSString *path = @"/Library/Application Support/WeatherWhirl/Forecast.plist";
    #else
    NSString *path = ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/Forecast.plist");
    #endif
    struct tm *gmcurtime = NULL;
    time_t temptime = time(NULL);
    gmcurtime = gmtime(&temptime);
    if(![fileManager fileExistsAtPath:path]) {
        return fetchForecast(gmcurtime, path);
    } else {
        NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:path];
        NSNumber *wasForDay = contents[@"forDay"];
        if([wasForDay intValue] != gmcurtime->tm_yday) {
            NSError *err;
            [fileManager removeItemAtPath:path error:&err];
            if(err) {
                NSLog(@"%@",err.description);
                return nil;
            }
            return fetchForecast(gmcurtime, path);
        } else {
        return contents[@"hourly"];
        }
    }
}
int getIDOfCurrentWeather() {
    NSArray *forecast = getForecast();
    if(forecast == nil) {
        NSLog(@"I appear to have encountered an error getting the forecast for today... Returning!");
        return 0;
    }
    time_t curTime = time(NULL); 
    struct tm *curGMTime = gmtime(&curTime);
    for(NSDictionary *hour in forecast) {
        NSNumber *NSdt = hour[@"dt"];
        time_t dt = (time_t)[NSdt longValue];
        struct tm *dgmt = gmtime(&dt);
        if(dgmt->tm_hour != curGMTime->tm_hour) {
            free(dgmt);
            continue;
        }
        return [((NSNumber *)(hour[@"weather"][0][@"id"])) intValue];
    }
    return 0;
}

UIImage *UIImageForCurrentWeather() {
    time_t curtime = time(NULL);
    if(cachedImage == nil || (cachedTime != NULL && cachedTime->tm_hour != gmtime(&curtime)->tm_hour)) {
    int id = getIDOfCurrentWeather();
    NSString *filePath = @"";
    NSLog(@"Current Weather ID: %d",id);
    switch(id) {
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
    }
    NSLog(@"%@",filePath);
    if([filePath isEqualToString:@""]) {
        return nil;
    }
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    cachedImage = img;
    AntiARCRetain(cachedImage);
    cachedTime = gmtime(&curtime);
    return cachedImage;
    } else {
        return cachedImage;
    }
}