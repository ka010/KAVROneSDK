//
//  VROneView.h
//  DroneTest
//
//  Created by Kai Aras on 26/02/15.
//  Copyright (c) 2015 Kai Aras. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface KAVROneView : UIView

@property(nonatomic,assign,setter=setPredestortionEnabled:) BOOL isPredestortionEnabled;    // toggle pre-distortion

@property(nonatomic,assign,setter=setSplitViewEnabled:) BOOL isSplitViewEnabled;    // toggle split-view

// update display with CIImage
-(void)displayFrame:(CIImage*)frame;

@end
