//
//  TPHData.m
//  BLEBridge
//
//  Created by Supat Saetia on 9/28/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import "TPHData.h"

@implementation TPHData

@synthesize rawData;
@synthesize emgValue;
@synthesize emgData;
@synthesize headerData;
@synthesize emgValueForJointEstimation;

@synthesize sensor1;
@synthesize sensor2;
@synthesize sensor3;
@synthesize sensor4;
@synthesize sensor5;
@synthesize sensor6;

@synthesize processed1;
@synthesize processed2;
@synthesize processed3;
@synthesize processed4;
@synthesize processed5;
@synthesize processed6;

- (id) init
{
    self = [super init];
    if (self) {
        rawData = [[NSData alloc] init];
        emgData = [[NSMutableArray alloc] init];
        emgValue = [[NSMutableArray alloc] init];
        headerData = [[NSData alloc] init];
    }
    
    return self;
}

- (id) initWithRawData:(NSData *)data
{
    self = [super init];
    if (self) {
        rawData = data;
        headerData = [self extractDataHeader];
        emgData = [self extractRawSensorData];
        emgValue = [self decodeEMGFromRaw];
        emgValueForJointEstimation = [self preprocessEMGForJointEstimation];
    }
    
    return self;
}

- (NSData *)extractDataHeader
{
    return [rawData subdataWithRange:NSMakeRange(0, 1)];
}

- (NSMutableArray *)extractRawSensorData
{
    NSMutableArray *rawBytes = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 19; i = i + 3) {
        [rawBytes addObject:[rawData subdataWithRange:NSMakeRange(i, 3)]];
    }
    
    return rawBytes;
}

- (NSMutableArray *)decodeEMGFromRaw
{
    NSMutableArray *signal = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 6; i++) {
        double value = 0;
        for (int j = 0; j < 3; j++) {
            NSData *data = [[emgData objectAtIndex:i] subdataWithRange:NSMakeRange(j, 1)];
            value += CFSwapInt16LittleToHost(*(int*)[data bytes]) << (8 * (2 - j));
        }
        value /= 256 * 256 * 128.0 * 2;
        NSNumber *num = [NSNumber numberWithDouble:value];
        [signal addObject:num];
        
    }
    
//    NSLog(@"%@ %f %f %f %f %f %f", rawData,
//          [[signal objectAtIndex:0] doubleValue],
//          [[signal objectAtIndex:1] doubleValue],
//          [[signal objectAtIndex:2] doubleValue],
//          [[signal objectAtIndex:3] doubleValue],
//          [[signal objectAtIndex:4] doubleValue],
//          [[signal objectAtIndex:5] doubleValue]
//          );
    
    sensor1 = [[signal objectAtIndex:0] floatValue];
    sensor2 = [[signal objectAtIndex:1] floatValue];
    sensor3 = [[signal objectAtIndex:2] floatValue];
    sensor4 = [[signal objectAtIndex:3] floatValue];
    sensor5 = [[signal objectAtIndex:4] floatValue];
    sensor6 = [[signal objectAtIndex:5] floatValue];
    
    return signal;
}

- (NSMutableArray *)preprocessEMGForJointEstimation
{
    NSMutableArray *signal = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 6; i++) {
        double value = [[emgValue objectAtIndex:i] doubleValue];
        NSNumber *num = [NSNumber numberWithDouble:fabs(value - 0.5)];
        [signal addObject:num];
    }
    
    processed1 = [[signal objectAtIndex:0] floatValue];
    processed2 = [[signal objectAtIndex:1] floatValue];
    processed3 = [[signal objectAtIndex:2] floatValue];
    processed4 = [[signal objectAtIndex:3] floatValue];
    processed5 = [[signal objectAtIndex:4] floatValue];
    processed6 = [[signal objectAtIndex:5] floatValue];
    
    return signal;
}

@end
