#ifndef CLOUDVIEW_H
#define CLOUDVIEW_H
#define UIViewParentController(__view) ({ \
    UIResponder *__responder = __view; \
    while ([__responder isKindOfClass:[UIView class]]) \
        __responder = [__responder nextResponder]; \
    (UIViewController *)__responder; \
})
    #include <UIKit/UIKit.h>
    #include "HomeScreenView.h"
    @interface CloudView: UIView
        @property (nonatomic) NSArray *clouds;
        -(void)placeClouds:(CloudyTypes)cloudType : (UIImage *)cloud : (RainTypes)rain;
        -(void)debugClouds;
    @end
#endif