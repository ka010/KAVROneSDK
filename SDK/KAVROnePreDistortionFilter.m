//
//  VROneFilter.m
//  DroneTest
//
//  Created by Kai Aras on 05/02/15.
//  Copyright (c) 2015 Kai Aras. All rights reserved.
//

#import "KAVROnePreDistortionFilter.h"
#import <Foundation/Foundation.h>


@implementation KAVROnePreDistortionFilter

static CIImage *LuT_XB = nil;
static CIImage *LuT_YB = nil;
static CIImage *LuT_XG = nil;
static CIImage *LuT_YG = nil;
static CIImage *LuT_XR = nil;
static CIImage *LuT_YR = nil;


- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(CIKernel*)_kernel {
    static CIKernel *kernel =nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSObject *null = [NSNull null];
        
        UIImage *img = [UIImage imageNamed:@"LUT_XB"];
        LuT_XB = [CIImage imageWithCGImage:img.CGImage options:@{kCIImageColorSpace: null}];
        
        UIImage *imgY = [UIImage imageNamed:@"LUT_YB"];
        LuT_YB = [CIImage imageWithCGImage:imgY.CGImage options:@{kCIImageColorSpace: null}];
        
        UIImage *xg = [UIImage imageNamed:@"LUT_XG"];
        LuT_XG = [CIImage imageWithCGImage:xg.CGImage options:@{kCIImageColorSpace: null}];
        
        UIImage *yg = [UIImage imageNamed:@"LUT_YG"];
        LuT_YG = [CIImage imageWithCGImage:yg.CGImage options:@{kCIImageColorSpace: null}];
        
        UIImage *xr = [UIImage imageNamed:@"LUT_XR"];
        LuT_XR = [CIImage imageWithCGImage:xr.CGImage options:@{kCIImageColorSpace: null}];
        
        UIImage *yr = [UIImage imageNamed:@"LUT_YR"];
        LuT_YR = [CIImage imageWithCGImage:yr.CGImage options:@{kCIImageColorSpace: null}];
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"vrOneLuTDistortion" ofType:@"kernel"];
        NSString *kernelString= [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIKernel kernelWithString:kernelString];
    });
    return kernel;
    
}

-(CIImage *)outputImage{
    
    CGRect extend = LuT_XB.extent; // output should be the same size as the LuTs are so set the kernel extent to any of them
    return [[self _kernel]applyWithExtent:extend roiCallback:^CGRect(int index, CGRect rect) {
        // the kernel will use this rect when mapping pixel to world coordinates in the samplerTransform() call
        if (index == 0) {
            return  _inputImage.extent; // dimensions of our input image
        }else {
            return LuT_XB.extent; // all the LuTs have the same dimensions so we don't need a separate if for each of them
        }
        
    } arguments:@[_inputImage, @(_mirrorFlag), LuT_XB, LuT_YB, LuT_XG, LuT_YG, LuT_XR, LuT_YR]];
}

@end
