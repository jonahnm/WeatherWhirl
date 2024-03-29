#include <AVFoundation/AVGeometry.h>
#include <CoreFoundation/CFCGTypes.h>
#include <CoreGraphics/CGGeometry.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSDictionary.h>
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
@implementation UIScreen (random)
-(CGPoint)randomPointWithCloudView:(CloudView *)cloudview {
    @autoreleasepool {
    CGPoint point = CGPointMake(arc4random_uniform(self.bounds.size.width), arc4random_uniform(self.bounds.size.height));
    for (UIView *view in cloudview.subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return [self randomPointWithCloudView:cloudview];
        }
    }
    return point;
    }
}
@end
@implementation  HomeScreenView : UIView
    -(void) updater {
        isUpdating = YES;
        time_t curtime = time(NULL);
        struct tm *curGMTime = gmtime(&curtime);
        NSTimeInterval delay = ((60-curGMTime->tm_min)*60);
        [self performSelector:@selector(updater) withObject:self afterDelay:delay];
        free(curGMTime);
    }
    -(void)setImgView:(UIImageView *)imgView {
        if(_imgView) {
        [_imgView removeFromSuperview];
        }
        _imgView = imgView;
        imgView.backgroundColor = UIColor.clearColor;
        [self addSubview:imgView];
        [self sendSubviewToBack:imgView];
    }
    -(void)setCloudView:(id)cloudView {
        _cloudView = cloudView;
        CloudView *view = cloudView;
        view.bounds = UIScreen.mainScreen.bounds;
        view.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
        [self addSubview:cloudView];
        [self bringSubviewToFront:cloudView];
    }
    -(void)setAnimatedImgView:(FLAnimatedImageView *)animatedImgView {
        if(_animatedImgView) {
            [_animatedImgView removeFromSuperview];
        }
        _animatedImgView = animatedImgView;
        [self addSubview:animatedImgView];
        [self bringSubviewToFront:animatedImgView];
        [animatedImgView layoutIfNeeded];
        [self layoutIfNeeded];
    }
    -(void)placeClouds:(int)weatherID {
        CloudView *cloudViewlocal = self.cloudView;
        UIImage *cloud = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/cloud.png")];
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
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        imageView.animatedImage = animImg;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.animatedImgView = imageView;
        switch(whereto) {
            case TopLeftCorner:
            ;
                NSArray *vertConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imgView]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{
                    @"imgView": imageView
            }];
            NSArray *horizConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imgView]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{
                    @"imgView": imageView
            }];
            [self addConstraints:vertConstraints];
            [self addConstraints:horizConstraints];
            break;
        }
    }
    -(BOOL) setBackgroundWithImage:(id)img {
        if([img isKindOfClass:[UIImage class]]) {
        UIImage *scaledImage = [img resizedImageWithBounds:UIScreen.mainScreen.bounds.size];
        self.imgView = [[UIImageView alloc] initWithImage:scaledImage];
        }else if([img isKindOfClass:[FLAnimatedImage class]]) {
            self.imgView = [[FLAnimatedImageView alloc] init];
            CGSize mainScreenSize = UIScreen.mainScreen.bounds.size;
            CGFloat mainScreenScale = UIScreen.mainScreen.scale;
            CGRect boundsnframe = CGRectMake(0,0,mainScreenSize.width * mainScreenScale,mainScreenSize.height * mainScreenScale);
            ((FLAnimatedImageView *)self.imgView).bounds = boundsnframe;
            ((FLAnimatedImageView *)self.imgView).frame = boundsnframe;
            ((FLAnimatedImageView *)self.imgView).animatedImage = (FLAnimatedImage *)img;
        }
        if(!isUpdating) {
            [self updater];
        }
        return YES;
    }
@end