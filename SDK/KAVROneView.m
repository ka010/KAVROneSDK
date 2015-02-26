//
//  VROneView.m
//  DroneTest
//
//  Created by Kai Aras on 26/02/15.
//  Copyright (c) 2015 Kai Aras. All rights reserved.
//

#import "KAVROneView.h"
#import "KAVROnePreDistortionFilter.h"

@interface KAVROneView() {
    KAVROnePreDistortionFilter *_preDistortionFilter;
    EAGLContext *_eaglContext;
    CIContext *_ciContext;
    GLKView *_glkView;
    CGRect _glkViewBounds;
    
    CIImage *_inFrame;
}

@end

@implementation KAVROneView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}


#pragma mark - Private

-(void)_init {
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    _glkView = [[GLKView alloc] initWithFrame:self.bounds context:_eaglContext];
    _glkView.enableSetNeedsDisplay = NO;
    // _glkView.transform = CGAffineTransformMakeRotation(M_PI);
    
    [self.layer addSublayer:_glkView.layer];
    
    // disable color managment for the context, this ensures proper display of our filter output
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    [_glkView bindDrawable];
    _glkViewBounds = CGRectZero;
    _glkViewBounds.size.width = _glkView.drawableWidth;
    _glkViewBounds.size.height = _glkView.drawableHeight;
    
    _preDistortionFilter = [KAVROnePreDistortionFilter new];
    
}

// apply pre-distortion to a given image, set mirror flag for right eye view
-(CIImage*)_applyPreDistortionForImage:(CIImage*)input mirror:(BOOL)mirror{
    CIImage *result;
    _preDistortionFilter.inputImage = input;
    _preDistortionFilter.mirrorFlag = mirror;
    result = [_preDistortionFilter valueForKey:kCIOutputImageKey];
    return result;
}

-(void)_drawLeftEye {
    CIImage *leftEyeFrame =nil;
    if (_isPredestortionEnabled) {
        leftEyeFrame = [self _applyPreDistortionForImage:_inFrame mirror:NO];
    }else{
        leftEyeFrame = _inFrame;
    }
    [_ciContext drawImage:leftEyeFrame inRect:CGRectMake(0, 0, kKAVROneFilterLuTWidth, kKAVROneFilterLuTHeight) fromRect:leftEyeFrame.extent];
    
}

-(void)_drawRightEye {
    CIImage *rightEyeFrame = nil;
    if (_isPredestortionEnabled) {
        rightEyeFrame = [self _applyPreDistortionForImage:_inFrame mirror:YES];
    }else{
        rightEyeFrame = _inFrame;
    }
    [_ciContext drawImage:rightEyeFrame inRect:CGRectMake(kKAVROneFilterLuTWidth, 0, kKAVROneFilterLuTWidth, kKAVROneFilterLuTHeight) fromRect:rightEyeFrame.extent];
}



#pragma mark - Public

-(void)displayFrame:(CIImage*)frame {
    if (!frame) {
        return;
    }
    
    _inFrame = frame;
    
    [_glkView bindDrawable]; // bind the framebuffer
    
    if (_eaglContext != [EAGLContext currentContext]) // make sure our eaglContext is the current context
        [EAGLContext setCurrentContext:_eaglContext];
    
    
    if (!_isSplitViewEnabled) {
        [_ciContext drawImage:_inFrame inRect:_glkViewBounds fromRect:_inFrame.extent]; // draw fullscreen frame, pre-distortion disabled
    }else {
        [self _drawLeftEye];    // draw the left eye frame at half the view width
        
        [self _drawRightEye];   // draw the right eye frame at half the view width, offset by half the view width
    }
    
    [_glkView display]; // update the display
    
}


@end
