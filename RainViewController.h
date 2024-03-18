#ifndef RAINVIEWCONTROLLER_H
#define RAINVIEWCONTROLLER_H
#include <UIKit/UIKit.h>
@interface RainViewController: UIViewController
    @property int curframeindex;
    @property NSArray *frames;
    -(instancetype)initWithFrames: (NSArray *)frames;
@end
#endif