//
//  ViewController.m
//  VROneShaderTest
//
//  Created by Kai Aras on 25/02/15.
//  Copyright (c) 2015 Kai Aras. All rights reserved.
//

#import "ViewController.h"
#import "KAVROneView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () {
    
    AVCaptureSession *_captureSession;
    CMVideoDimensions _currentVideoDimensions;
    
    KAVROneView *_vrOneView;
    
    CIImage *_cameraFrame;
    dispatch_queue_t _captureSessionQueue;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vrOneView = [[KAVROneView alloc]initWithFrame:self.view.bounds];
    [_vrOneView setSplitViewEnabled:YES];
    [_vrOneView setPredestortionEnabled:YES];
    
    [self.view addSubview:_vrOneView];
    
    [self _initCamera];
    
    [self _startCamera];
    
    [self _startDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - DisplayLink

-(void)_startDisplay {
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(_updateDisplay)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


// pass on the camera image, create split-view, apply pre-distortion and update the display
-(void)_updateDisplay {
    [_vrOneView displayFrame:_cameraFrame];
}


#pragma mark - Camera
- (void) _initCamera {
    
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *backCamera =nil;
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
        }
    }
    
    if (backCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [_captureSession addInput:input];
    }else {
        NSLog(@"Only Back Camera supported!");
        return;
    }
    
    
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    [output setSampleBufferDelegate:self queue:_captureSessionQueue];
    [_captureSession addOutput:output];
    
    
}

-(void)_startCamera {
    [_captureSession startRunning];
    
}


-(void)_stopCamera {
    [_captureSession stopRunning];
    
}

#pragma mark -


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    _cameraFrame = [CIImage imageWithCVPixelBuffer:pixelBuffer]; // grab the camera image and store it in an iVar
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
}

@end
