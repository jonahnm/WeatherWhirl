#include "RainViewController.h"
#include <CoreFoundation/CFCGTypes.h>
#include <Foundation/NSArray.h>
#include <UIKit/UIImageView.h>
#include <UIKit/UIScreen.h>
#include <UIKit/UIView.h>
#include <time.h>
@implementation RainViewController : UIViewController
    -(instancetype)initWithFrames: (NSArray *)frames {
        self = [super init];
        self.curframeindex = 0;
        NSMutableArray *scaledFrames = [frames mutableCopy];
        for(int i = 0; i < [scaledFrames count]; i++) {
            CGSize bounds = UIScreen.mainScreen.bounds.size;
            UIImage *img = scaledFrames[i];
            CGFloat screenScale = UIScreen.mainScreen.scale;
            CGSize newSize = CGSizeMake(img.size.width, (bounds.height) * screenScale);
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
            [img drawInRect:CGRectMake(0, 0,newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            scaledFrames[i] = newImage;
        }
        self.frames = scaledFrames;
        return self;
    }
    -(void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        [((UIImageView *)self.view) setImage:self.frames[self.curframeindex]];
        self.curframeindex += 1;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            struct timespec starttime;
            clock_gettime(CLOCK_MONOTONIC_RAW, &starttime); 
            while(self.beingPresented) {
                struct timespec nowtime;
                clock_gettime(CLOCK_MONOTONIC_RAW, &nowtime);
                if(((nowtime.tv_sec - starttime.tv_sec) * 1000 + (nowtime.tv_nsec - starttime.tv_nsec) / 1000000) >= 150) {
                    [((UIImageView *)self.view) setImage:self.frames[self.curframeindex]];
                    self.curframeindex += 1;
                    if(self.curframeindex > (self.frames.count-1)) self.curframeindex = 0;
                    clock_gettime(CLOCK_MONOTONIC_RAW, &starttime);
                }
            }
        });
    }
@end