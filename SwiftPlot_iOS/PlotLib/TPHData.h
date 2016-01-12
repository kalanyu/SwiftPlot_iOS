//
//  TPHData.h
//  BLEBridge
//
//  Created by Supat Saetia on 9/28/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPHData : NSObject

@property (readonly) NSData *rawData;
@property (readonly) NSMutableArray *emgData;
@property (readonly) NSMutableArray *emgValue;
@property (readonly) NSMutableArray *emgValueForJointEstimation;
@property (readonly) NSData *headerData;

@property (readonly) float sensor1;
@property (readonly) float sensor2;
@property (readonly) float sensor3;
@property (readonly) float sensor4;
@property (readonly) float sensor5;
@property (readonly) float sensor6;

@property (readonly) float processed1;
@property (readonly) float processed2;
@property (readonly) float processed3;
@property (readonly) float processed4;
@property (readonly) float processed5;
@property (readonly) float processed6;

- (id) initWithRawData:(NSData *)data;

@end
