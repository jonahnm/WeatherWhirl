#include "CloudView.h"
#include "HomeScreenView.h"
#include "WeatherHandler.h"
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
#include <Foundation/NSURL.h>
#include <ModelIO/MDLAsset.h>
#include <ModelIO/ModelIO.h>
#include <SceneKit/SCNGeometry.h>
#include <SceneKit/SCNMaterial.h>
#include <SceneKit/SCNParametricGeometry.h>
#include <SceneKit/SCNParticleSystem.h>
#include <SceneKit/SCNScene.h>
#include <SceneKit/SceneKit.h>
#include <SceneKit/SceneKitTypes.h>
#include <UIKit/UIColor.h>
#include <UIKit/UIGeometry.h>
#include <UIKit/UIKit.h>
#include <UIKit/UIScreen.h>
#include <UIKit/UIViewController.h>
#include <math.h>
#include <objc/NSObjCRuntime.h>
#include <stdlib.h>
#import <SceneKit/ModelIO.h>
@import SceneKit;
#define LOG_EXPR(_X_) do{\
2 	__typeof__(_X_) _Y_ = (_X_);\
3 	const char * _TYPE_CODE_ = @encode(__typeof__(_X_));\
4 	NSString *_STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_);\
5 	if(_STR_)\
6 		NSLog(@"%s = %@", #_X_, _STR_);\
7 	else\
8 		NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__);\
9 }while(0)
SCNParticleSystem *createSplashSystem() {
    SCNParticleSystem *spSystem = [SCNParticleSystem particleSystem];
    spSystem.emissionDuration = 0;
    spSystem.loops = NO;
    spSystem.birthRate = 10;
    spSystem.birthRateVariation = 5;
    spSystem.emitterShape = [SCNSphere sphereWithRadius:3.5];
    spSystem.birthLocation = SCNParticleBirthLocationVolume;
    spSystem.birthDirection = SCNParticleBirthDirectionRandom;
    spSystem.particleVelocity = 5.5;
    spSystem.particleLifeSpan = 2.5;
    spSystem.particleSize = 2.5;
    spSystem.particleSizeVariation = 0.25;
    spSystem.particleColor = UIColor.blueColor;
    spSystem.affectedByGravity = YES;
    return spSystem;
}
@implementation Cloud : SCNNode 
    +(instancetype)nodeWithCloudImg:(UIImage *)img {
    if(Storage.cloud == nil) {
       MDLAsset *cloudstl = [[MDLAsset alloc] initWithURL:[NSURL fileURLWithPath:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/cloud.stl")]]; 
        MDLMesh *mesh = (MDLMesh *)[cloudstl objectAtIndex:0];
       SCNGeometry *cloud = [SCNGeometry geometryWithMDLMesh:mesh];
       SCNMaterial *tex = [SCNMaterial material];
       tex.diffuse.contents = img;
       cloud.firstMaterial = tex;
       Cloud *node = (Cloud *)[super nodeWithGeometry:cloud];
       node.scale = SCNVector3Make(10, 10, 10);
       Storage.cloud = [node copy];
       return node;
    } else {
        return [Storage.cloud copy];
    }
    }
    -(void)startRain:(RainTypes)type {
      //  self.scale = SCNVector3Make(UIScreen.mainScreen.bounds.size.width, 10, 0);
        SCNParticleSystem *rainSystem = [SCNParticleSystem particleSystem];
        rainSystem.particleColor = UIColor.blueColor;
        rainSystem.warmupDuration = 2.5;
        rainSystem.emissionDuration = 7.5;
        rainSystem.loops = YES;
        switch(type) {
            case Light:
                rainSystem.birthRate = 20;
                break;
            case Moderate:
                rainSystem.birthRate = 40;
                break;
            case Heavy:
                rainSystem.birthRate = 80;
                break;
            case EXTREME:
                rainSystem.birthRate = 160;
                break;
            default:   
            //unimplemented
                rainSystem.birthRate = 1; 
                break;
        }
        rainSystem.birthRateVariation = 14;
        rainSystem.emitterShape = self.geometry;
        rainSystem.emittingDirection = SCNVector3Make(0.0, -1.0, 0.0);
        rainSystem.spreadingAngle = 55;
        rainSystem.particleLifeSpan = 5;
        rainSystem.particleSize = 5;
        rainSystem.particleSizeVariation = 4.75;
        rainSystem.affectedByGravity = YES;
        rainSystem.colliderNodes = [[[self parentNode] parentNode] childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop){
            return [child isKindOfClass:[Icon class]];
        }]; // placeholder
        rainSystem.particleMass = 0.034/1000;
        rainSystem.particleMassVariation = 0.024/1000;
        rainSystem.particleBounce = 0;
        /*
        [rainSystem handleEvent:SCNParticleEventCollision forProperties:@[SCNParticlePropertyContactPoint,SCNParticlePropertyLife] withBlock:^(void **data,size_t *dataStride,uint32_t *indices,NSInteger count){
            for(NSInteger i = 0; i < count; i++) {
                float *contactPoint = (float *)((char *)data[0] + dataStride[0] * indices[i]);
                float *life = (float *)((char *)data[1] + dataStride[1] * indices[i]);
                NSArray *children = [[[self parentNode] parentNode] childNodesPassingTest:^(SCNNode *child, BOOL *stop){
                    if(![child isKindOfClass:[Icon class]]) {
                        return NO;
                    }
                    SCNVector3 min;
                    SCNVector3 max;
                    [child getBoundingBoxMin:&min max:&max];
                    BOOL contains =
        min.x <= contactPoint[0] &&
    min.y <= contactPoint[1] &&
    min.z <= contactPoint[2] &&

    max.x > contactPoint[0] &&
    max.y > contactPoint[1] &&
    max.z > contactPoint[2];
    return contains;
                }];
                if(children != nil && children.count != 0) {
                    life[0] = 0;
                    SCNParticleSystem *splash = createSplashSystem();
                    [Storage.sceneView.scene addParticleSystem:splash withTransform:SCNMatrix4MakeTranslation(contactPoint[0], contactPoint[1], contactPoint[2])];
                }
            }
        }];
        */
        rainSystem.systemSpawnedOnCollision = createSplashSystem();
       [self addParticleSystem:rainSystem];
    }
@end
@implementation Clouds : SCNNode
    -(void)placeClouds:(CloudyTypes)cloudType : (UIImage *)cloud : (RainTypes)rain {
        double coveragePercent = 0.0;
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
            CGPoint randomPoint = [UIScreen.mainScreen randomPointWithCloudView:self];
            Cloud *mycloud = [Cloud nodeWithCloudImg:cloud];
            [self addChildNode:mycloud];
            [mycloud startRain:rain];
            mycloud.position = SCNVector3Make(randomPoint.x, randomPoint.y, 0);
    }
    }
    -(void)debugClouds {
        UIImage *img = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/WeatherWhirl/cloud.png")];
        [self placeClouds:ScatterClouds :img : None]; 
    }
@end