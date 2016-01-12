//
//  TPHEMGSensor.h
//  TPHBridge
//
//  Created by Supat Saetia on 9/25/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TPHData.h"

@class TPHEMGSensor;
@protocol TPHEMGSensorDelegate <NSObject>
- (void)TPHEMGSensorDidReceiveDataFromRemoteSensor:(TPHData *)data;
- (void)TPHEMGSensorDidUpdateConnectionState:(BOOL)connected;
- (void)TPHEMGSensorDidUpdateStatusMessage:(NSString *)status;
- (void)TPHEMGSensorDidUpdateState;
- (void)TPHEMGSensorDidUpdateADCSetting:(NSData *)setting;

@end

@interface TPHEMGSensor : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *centralManager;
    CBPeripheral *m_peripheral;
    CBCharacteristic *emg_characteristic;
    CBCharacteristic *setting_characteristic;
    CBCharacteristic *command_characteristic;
    
    NSData *startByte;
    NSData *stopByte;
    NSData *ADCByte;
    
    CBUUID *TPHEMGSensorServiceUUID;
    CBUUID *TPHControlServiceUUID;
    CBUUID *TPHEMGSignalCharacteristicUUID;
    CBUUID *TPHADCSettingCharacteristicUUID;
    CBUUID *TPHCommandCharacteristicUUID;
    
    dispatch_queue_t centralQueue;
    
    BOOL _connectionState;
}

@property (retain) id delegate;
@property (nonatomic, readonly) BOOL connectionState;
@property (readonly) NSData *ADCSettingByte;
@property (readonly) NSString *TPHEMGDeviceName;

extern BOOL TPHEMGSensorStateScanning;
extern BOOL TPHEMGSensorStateStopScanning;
extern BOOL TPHEMGSensorStateDiscovered;
extern BOOL TPHEMGSensorStateConnected;
extern BOOL TPHEMGSensorStateDisconnected;
extern BOOL TPHEMGSensorStateListening;
extern BOOL TPHEMGSensorStateTransmitting;

@property (readonly) int sensorGain1;
@property (readonly) int sensorGain2;
@property (readonly) int sensorGain3;
@property (readonly) int sensorGain4;
@property (readonly) int sensorGain5;
@property (readonly) int sensorGain6;
@property (readonly) int sensorOverSample1;
@property (readonly) int sensorOverSample2;
@property (readonly) int sensorOverSample3;
@property (readonly) int sensorOverSample4;
@property (readonly) int sensorOverSample5;
@property (readonly) int sensorOverSample6;

- (void)scanForRemoteSensor;
- (void)disconnectFromRemoteSensor;
- (void)requestADCSettingInformation;
- (void)setSensor:(int8_t)sensorNumber gainLevelTo:(int8_t)level;
- (void)setSensor:(int8_t)sensorNumber overSampleLevelTo:(int8_t)level;


@end
