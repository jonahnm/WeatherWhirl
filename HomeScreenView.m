#include <AVFoundation/AVGeometry.h>
#include <CoreFoundation/CFCGTypes.h>
#include <CoreGraphics/CGGeometry.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSDictionary.h>
#include <SceneKit/SCNGeometry.h>
#include <SceneKit/SCNMaterial.h>
#include <SceneKit/SCNNode.h>
#include <SceneKit/SceneKit.h>
#include <SceneKit/SceneKitTypes.h>
#include <UIKit/NSLayoutConstraint.h>
#include <UIKit/UIKit.h>
#include <UIKit/UIScreen.h>
#include <stdlib.h>
#include <time.h>
#include <AVFoundation/AVFoundation.h>
#include "CloudView.h"
#include "FLAnimatedImage/FLAnimatedImage.h"
#include "FLAnimatedImage/FLAnimatedImageView.h"
#include "HomeScreenView.h"
#include "rootless.h"
#include <UIKit/NSLayoutConstraint.h>
@import SceneKit;
@implementation UIScreen (random)
-(CGPoint)randomPointWithCloudView:(Cloud *)cloudview {
    CGPoint point = CGPointMake(arc4random_uniform(self.bounds.size.width), arc4random_uniform(self.bounds.size.height));
    return point;
}
@end
@implementation  HomeScreen : SCNScene
    -(void) updater {
        // stub
    }
    -(void)setCloudView:(id)cloudView {
        _cloudView = cloudView;
        Clouds *cloudslocal = cloudView;
        [self.rootNode addChildNode:cloudslocal];
    }
    -(void)setAnimatedImgView:(FLAnimatedImageView *)animatedImgView {
        _animatedImgView = animatedImgView;
        // stub
    }
    +(instancetype)scene {
    HomeScreen *inst = [super scene];
    for(Icon *icon in Storage.queuedIcons) {
        [inst.rootNode addChildNode:icon];
    }
    return inst;
    }
    -(void)placeClouds:(int)weatherID {
        Clouds *cloudViewlocal = self.cloudView;
        UIImage *cloud = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/cloudtex.jpg")];
        UIImage *sephiroth = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/sephiroth.png")];
        switch(weatherID) {
            case 801:
                [cloudViewlocal placeClouds:FewClouds :cloud : None];
                break;
            case 802:
                [cloudViewlocal placeClouds:ScatterClouds :cloud : None];
                break;
            case 803:
                [cloudViewlocal placeClouds:BrokeClouds :cloud : None];
                break;
            case 804:
                [cloudViewlocal placeClouds:OverClouds :cloud : None];
                break;
            case 500:
                [cloudViewlocal placeClouds:FewClouds :sephiroth : Light];
                break;
            case 501:
                [cloudViewlocal placeClouds:ScatterClouds :sephiroth :Moderate];
                break;
            case 502:
                [cloudViewlocal placeClouds:BrokeClouds :sephiroth :Heavy];
                break;
            default:
                NSLog(@"Non-cloudy/rainy weather ID was passed into placeClouds, weather ID: %i",weatherID);
                break;
        }
    }
    -(void)setAnimationWithGif:(FLAnimatedImage *)animImg :(AnimPlace)whereto {
        // stub
        }
    -(BOOL) setBackgroundWithImage:(id)img {
        if([img isKindOfClass:[UIImage class]]) {
        self.background.contents = img;
        return YES;
    }
    return NO;
    }
@end
@implementation HomeScreenView: SCNView
@end
@implementation Icon: SCNNode
-(instancetype)initWithIconView:(UIImageView *)icon {
    self = [super init];
    SCNGeometry *geo = [SCNPlane planeWithWidth:icon.frame.size.width height:icon.frame.size.height];
    self.position = SCNVector3Make(icon.frame.origin.x, icon.frame.origin.y, 0);
    self.geometry = geo;
    self.opacity = 0;
    return self;
}
@end