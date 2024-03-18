#include "CloudView.h"
#include "HomeScreenView.h"
#include "RainViewController.h"
#include "rootless.h"
#include <CoreFoundation/CFCGTypes.h>
#include <CoreGraphics/CoreGraphics.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSFileManager.h>
#include <UIKit/UIKit.h>
#include <UIKit/UIScreen.h>
#include <math.h>
#include <stdlib.h>
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
        switch(rain) {
            case None:
                break;
            case Light:
            ;
                rainFramePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/lightrain/") error:NULL];
                break;
            case Moderate:
                break;
            case Heavy:
                break;
            case VeryHeavy:
                break;
            case EXTREME:
                break;
            case Freezing:
                break;
            case LightShower:
                break;
            case Shower:
                break;
            case HeavyShower:
                break;
            case RagShower:
                break;
        }
        if(rainFramePaths != nil) {
            NSMutableArray *imgs = [[NSMutableArray alloc] init];
            for(NSString *framePath in rainFramePaths) {
                imgs[imgs.count] = [UIImage imageWithContentsOfFile:framePath];
            }
            UIImageView *imageView = [[UIImageView alloc] init];
            RainViewController *rainController = [[RainViewController alloc] initWithFrames:imgs];
            rainController.view = imageView;
            [UIViewParentController(self) addChildViewController:rainController];
            [self addSubview:imageView];
            [self sendSubviewToBack:imageView];
        }
        NSLog(@"Coverage Percentage: %f",coveragePercent);
        double screenArea = (UIScreen.mainScreen.bounds.size.width * UIScreen.mainScreen.scale) * (UIScreen.mainScreen.bounds.size.height * UIScreen.mainScreen.scale);
        double imageArea = cloud.size.width * cloud.size.height;
        int requiredClouds = round(screenArea/imageArea * (coveragePercent/100));
        NSLog(@"Clouds needed to fill: %i",requiredClouds);
        for(int i = 0; i < requiredClouds; i++) {
            UIImageView *cloudimgView = [[UIImageView alloc] initWithImage:cloud];
            CGPoint randomPoint = [UIScreen.mainScreen randomPoint];
            [self addSubview:cloudimgView];
            [self bringSubviewToFront:cloudimgView];
            cloudimgView.frame = CGRectMake(randomPoint.x, randomPoint.y, cloud.size.width, cloud.size.height);
        }
    }
    -(void)debugClouds {
        UIImage *img = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/cloud.png")];
        [self placeClouds:ScatterClouds :img : None]; 
    }
@end