#include "WeatherHandler.h"
#include "libroot/libroot.h"
#import <CoreFoundation/CoreFoundation.h>
#include <Foundation/NSObjCRuntime.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSJSONSerialization.h>
#include <Foundation/NSString.h>
#include <Foundation/NSURLSession.h>
#include <CoreLocation/CLLocationManager.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <rootless.h>
int getIDOfCurrentWeather() {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    NSString *urlstr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=25944184269045c16e143b872e5b9f1d",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlstr];
    [locationManager stopUpdatingLocation];
    __block int out = 0;
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            return;
        }
        NSError *err;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err) {
            NSLog(@"%@",err.description);
            return;
        }
        NSLog(@"%@",results);
        NSArray *weatherarray = [results objectForKey:@"weather"];
        NSDictionary *weather = weatherarray[0];
        NSNumber *id = [weather objectForKey:@"id"];
        out = [id intValue];
    }];
    [downloadTask resume];
    return out;
}

UIImage *UIImageForCurrentWeather() {
    int id = getIDOfCurrentWeather();
    NSString *filePath = @"";
    switch(id) {
        case 801 ... 804:
        filePath = ROOTFS_PATH_NSSTRING(@"/Library/Application Support/WeatherWhirl/clearskies.jpg");
        break;
    }
    if([filePath isEqualToString:@""]) {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:filePath];
}