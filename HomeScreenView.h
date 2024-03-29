#ifndef HOMESCREENVIEW_H
#define HOMESCREENVIEW_H
#include <UIKit/UIView.h>
@import FLAnimatedImage;
#include "WeatherHandler.h"
#include <UIKit/UIImageView.h>
#include <UIKit/UIImage.h>
typedef enum {
    TopLeftCorner
} AnimPlace;
typedef enum {
    FewClouds,
    ScatterClouds,
    BrokeClouds,
    OverClouds
} CloudyTypes;
typedef enum {
    None,
    Light = 500,
    Moderate = 501,
    Heavy = 502,
    VeryHeavy = 503,
    EXTREME = 504,
    Freezing = 511,
    LightShower = 520,
    Shower = 521,
    HeavyShower = 522,
    RagShower = 531,
} RainTypes;
@interface UIScreen (random)
-(CGPoint)randomPointWithCloudView:(id)cloudView;
@end
@interface HomeScreenView: UIView
{
    BOOL isUpdating;
}
    @property (nonatomic) id cloudView;
    @property (nonatomic) id imgView;
    @property (nonatomic) FLAnimatedImageView *animatedImgView;
    @property (nonatomic) BOOL isAnimatedImageViewPersistent;
    -(void)updater;
    -(BOOL) setBackgroundWithImage:(id)img;
    -(void)setAnimationWithGif:(FLAnimatedImage *)animImg : (AnimPlace)whereto;
    -(void)placeClouds:(int)weatherID;
@end
#endif