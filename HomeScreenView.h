#ifndef HOMESCREENVIEW_H
#define HOMESCREENVIEW_H
#include <UIKit/UIView.h>
#include "WeatherHandler.h"
#include <UIKit/UIImageView.h>
#include <UIKit/UIImage.h>
@interface HomeScreenView: UIView
    @property (nonatomic) UIImageView *imgView;
    -(void)updater;
    -(BOOL) setBackgroundCurrentWeather;
@end
#endif