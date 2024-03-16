#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <time.h>
#include "HomeScreenView.h"
@implementation  HomeScreenView : UIView
    -(void) updater {
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
        [self addSubview:imgView];
        [self sendSubviewToBack:imgView];
    }
    -(BOOL) setBackgroundCurrentWeather {
        UIImage *img = UIImageForCurrentWeather();
        if(img == nil) {
            NSLog(@"Something went horribly wrong getting UIImage for current weather.");
            return NO;
        }
        self.imgView = [[UIImageView alloc] initWithImage:img];
        return YES;
    }
@end