# KAVROneSDK
CoreImage based SDK for the Zeiss VROne Headset

## KAVROneView

```objc
    _vrOneView = [[KAVROneView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_vrOneView];
```

### Updating the Display
Update the display by passing a CIImage object.  
```objc
  [_vrOneView displayFrame:imageFrame];
```

### SplitView
```objc
    [_vrOneView setSplitViewEnabled:YES];
```
![](https://raw.githubusercontent.com/ka010/KAVROneSDK/master/sample_vr.png)


### Pre-Distortion

```objc
    [_vrOneView setPredestortionEnabled:YES];
```

![](https://raw.githubusercontent.com/ka010/KAVROneSDK/master/sample_vr_predistortion.png)
