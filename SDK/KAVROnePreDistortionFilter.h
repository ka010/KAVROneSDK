//
//  VROneFilter.h
//  DroneTest
//
//  Created by Kai Aras on 05/02/15.
//  Copyright (c) 2015 Kai Aras. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

#define kKAVROneFilterLuTWidth 667.0
#define kKAVROneFilterLuTHeight 750.0

@interface KAVROnePreDistortionFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,assign) BOOL mirrorFlag; // NO = left eye | YES = left eye

@end