//
//  CLLocation+Sino.h
//
//
// 实现earth坐标(国外[WGS84])/mars坐标(国内[GCJ-02])/bearPaw(百度[BD-09])
// 坐标系间相互转换

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Sino)

- (CLLocation*) locationMarsFromEarth;
- (CLLocation*) locationBearPawFromMars;
- (CLLocation*) locationMarsFromBearPaw;

@end