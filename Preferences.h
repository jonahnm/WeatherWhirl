#ifndef PREFERENCES_H
#define PREFERENCES_H
#include <Foundation/Foundation.h>
#include <UIKit/UIkit.h>
@interface WWPreferences: NSObject
    +(BOOL)loadPrefsWithURL:(NSURL *)url;
    +(NSDictionary *)raw;
    +(BOOL)isEnabledTweak;
    +(BOOL)overrideNext;
    +(NSString *)override;
    +(void)freeMe;
    +(void)setOverrideNext:(BOOL)b;
    +(UIImage *)customBackground:(NSString *)For;
@end
#endif