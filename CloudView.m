#include "CloudView.h"
#include "HomeScreenView.h"
#include "rootless.h"
#include <CoreFoundation/CFCGTypes.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreGraphics/CGGeometry.h>
#include <CoreGraphics/CoreGraphics.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSError.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSObjCRuntime.h>
#include <UIKit/UIGeometry.h>
#include <UIKit/UIKit.h>
#include <UIKit/UIScreen.h>
#include <math.h>
#include <objc/NSObjCRuntime.h>
#include <stdlib.h>
#define LOG_EXPR(_X_) do{\
2 	__typeof__(_X_) _Y_ = (_X_);\
3 	const char * _TYPE_CODE_ = @encode(__typeof__(_X_));\
4 	NSString *_STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_);\
5 	if(_STR_)\
6 		NSLog(@"%s = %@", #_X_, _STR_);\
7 	else\
8 		NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__);\
9 }while(0)
@implementation CloudView : UIView
    -(void)placeClouds:(CloudyTypes)cloudType : (UIImage *)cloud : (RainTypes)rain {
        double coveragePercent = 0;
        NSArray *rainFramePaths = nil;
        switch(cloudType) {
            case FewClouds:
            ;
                coveragePercent = arc4random_uniform(25-11) + 11;
                break;
            case ScatterClouds:
            ;
                coveragePercent = arc4random_uniform(50-25) + 25;
                break;
            case BrokeClouds:
            ;
                coveragePercent = arc4random_uniform(84-51) + 51;
                break;
            case OverClouds:
            ;
                coveragePercent = arc4random_uniform(100-85) + 85;
                break;
        }
        if(rain != None) {
            NSError *err;
            rainFramePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/lightrain") error:&err];
            if(err) {
                NSLog(@"ERROR!");
                NSLog(@"%@",err);
                return;
            }
        }
        NSMutableArray *imgs = [[NSMutableArray alloc] init];
        if(rainFramePaths != nil) {
            for(NSString *frameName in rainFramePaths) {
                NSString *framePath = [ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/lightrain") stringByAppendingPathComponent:frameName];
                NSLog(@"%@",framePath);
                UIImage *img = [UIImage imageWithContentsOfFile:framePath];
                
                if(img != nil) {
                    [imgs addObject:img];
                }else {
                    NSLog(@"Image is nil!");
                }
            }
        }
        NSLog(@"Coverage Percentage: %f",coveragePercent);
        double screenArea = (UIScreen.mainScreen.bounds.size.width * UIScreen.mainScreen.scale) * (UIScreen.mainScreen.bounds.size.height * UIScreen.mainScreen.scale);
        double imageArea = cloud.size.width * cloud.size.height;
        int requiredClouds = round(screenArea/imageArea * (coveragePercent/100));
        NSLog(@"Clouds needed to fill: %i",requiredClouds);
        for(int i = 0; i < requiredClouds; i++) {
            @autoreleasepool {
            UIImageView *cloudimgView = [[UIImageView alloc] initWithImage:cloud];
            CGPoint randomPoint = [UIScreen.mainScreen randomPointWithCloudView:self];
           // NSLog(@"Before convert: %@",NSStringFromCGPoint(randomPoint));
           // randomPoint = [UIScreen.mainScreen.coordinateSpace convertPoint:randomPoint toCoordinateSpace:self.coordinateSpace];
           // NSLog(@"After convert: %@",NSStringFromCGPoint(randomPoint));
            [self addSubview:cloudimgView];
            [self bringSubviewToFront:cloudimgView];
            cloudimgView.frame = CGRectMake(randomPoint.x, randomPoint.y, cloud.size.width, cloud.size.height);
             if(rainFramePaths != nil) {
            CGRect frame2 = [UIScreen.mainScreen.coordinateSpace convertRect:cloudimgView.frame fromCoordinateSpace:cloudimgView];
            UIImageView *animImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cloudimgView.frame.origin.x, cloudimgView.frame.origin.y, cloudimgView.frame.size.width, (UIScreen.mainScreen.bounds.size.height - CGRectGetMinY(frame2)))];
            animImageView.animationImages = imgs;
            animImageView.animationDuration = 0.15*4;
            if (rain == Moderate) {
                animImageView.animationDuration /= 1.25;
            } else if (rain == Heavy) {
                animImageView.animationDuration /= 1.5;
            } else if (rain == Light) {
                animImageView.animationDuration *= 2;
            }
            animImageView.animationRepeatCount = NSIntegerMax;
            [animImageView startAnimating];
            [cloudimgView addSubview:animImageView];
            [cloudimgView sendSubviewToBack:animImageView];
             }
        }
        }
    }
    -(void)debugClouds {
        UIImage *img = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/cloud.png")];
        [self placeClouds:ScatterClouds :img : None]; 
    }
@end