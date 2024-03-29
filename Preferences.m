#include "Preferences.h"
#include <Foundation/Foundation.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSValue.h>
#include "WeatherHandler.h"
@implementation WWPreferences : NSObject
    static NSMutableDictionary *prefs = nil;
    static NSURL *flushTo = nil;
    +(BOOL)loadPrefsWithURL:(NSURL *)url {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            return NO;
        }
        NSError *err;
        prefs = [[NSDictionary dictionaryWithContentsOfURL:url error:&err] mutableCopy];
        if(err) {
            NSLog(@"%@",err);
            return NO;
        }
        flushTo = url;
        AntiARCRetain(prefs);
        return YES;
    }
    +(NSDictionary *)raw {
        @synchronized (self) {return prefs;}
    }
    +(BOOL)isEnabledTweak {
       // if(prefs == nil) return NO;
        @synchronized (self){
            return YES;
        }
    }
    +(BOOL)overrideNext {
    if(prefs == nil) return NO;
    @synchronized (self){
        return [((NSNumber *)prefs[@"overrideNext"]) boolValue];
    }
    }
    +(NSString *)override {
        if(prefs == nil) return nil;
        @synchronized (self){
            return prefs[@"override"];
        }
    }
    +(void)freeMe {
        if(prefs == nil) return;
        AntiARCRelease(prefs);
    }
    +(void)setOverrideNext:(BOOL)b {
        if (flushTo == nil) {
        return;
        }
        prefs[@"overrideNext"] = [NSNumber numberWithBool:b];
        [prefs writeToURL:flushTo atomically:YES];
    }
    +(UIImage *)customBackground:(NSString *)For {
        if(prefs == nil) return nil;
        @synchronized (self){
            if([prefs objectForKey:@"customBackgrounds"] == nil) {
                return nil;
            } else if([prefs[@"customBackgrounds"] objectForKey:For] == nil) {
                return nil;
            }
            return [UIImage imageWithContentsOfFile:prefs[@"customBackgrounds"][For]];
        }
    }
@end