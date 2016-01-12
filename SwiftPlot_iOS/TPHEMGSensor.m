//
//  TPHEMGSensor.m
//  TPHBridge
//
//  Created by Supat Saetia on 9/25/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import "TPHEMGSensor.h"

BOOL TPHEMGSensorStateScanning = NO;
BOOL TPHEMGSensorStateStopScanning = NO;
BOOL TPHEMGSensorStateDiscovered = NO;
BOOL TPHEMGSensorStateConnected = NO;
BOOL TPHEMGSensorStateDisconnected = NO;
BOOL TPHEMGSensorStateListening = NO;
BOOL TPHEMGSensorStateTransmitting = NO;

@implementation TPHEMGSensor

@synthesize delegate;
@synthesize connectionState = _connectionState;
@synthesize ADCSettingByte;
@synthesize TPHEMGDeviceName;
@synthesize sensorGain1;
@synthesize sensorGain2;
@synthesize sensorGain3;
@synthesize sensorGain4;
@synthesize sensorGain5;
@synthesize sensorGain6;
@synthesize sensorOverSample1;
@synthesize sensorOverSample2;
@synthesize sensorOverSample3;
@synthesize sensorOverSample4;
@synthesize sensorOverSample5;
@synthesize sensorOverSample6;

- (id)init
{
    self = [super init];
    if (self) {
        TPHEMGSensorServiceUUID = [CBUUID UUIDWithString:@"D93F9B06-2730-4851-B55F-D80F80563545"];
        TPHControlServiceUUID = [CBUUID UUIDWithString:@"45355680-0FD8-5FB5-5148-3027069B3FD9"];
        TPHEMGSignalCharacteristicUUID = [CBUUID UUIDWithString:@"45355681-0FD8-5FB5-5148-3027069B3FDA"];
        TPHADCSettingCharacteristicUUID = [CBUUID UUIDWithString:@"45355681-0FD8-5FB5-5148-3027069B3FDB"];
        TPHCommandCharacteristicUUID = [CBUUID UUIDWithString:@"45355683-0FD8-5FB5-5148-3027069B3FDC"];
        
        startByte = [NSData dataWithBytes:"\xF1" length:1];
        stopByte = [NSData dataWithBytes:"\xF2" length:1];
        ADCByte = [NSData dataWithBytes:"\xF3" length:1];
        
        centralQueue = dispatch_queue_create("mycentralqueue", DISPATCH_QUEUE_SERIAL);
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
        
        _connectionState = NO;
        
        sensorGain1 = 0;
        sensorGain2 = 0;
        sensorGain3 = 0;
        sensorGain4 = 0;
        sensorGain5 = 0;
        sensorGain6 = 0;
        sensorOverSample1 = 0;
        sensorOverSample2 = 0;
        sensorOverSample3 = 0;
        sensorOverSample4 = 0;
        sensorOverSample5 = 0;
        sensorOverSample6 = 0;
        
        
        
    }
    return self;
}

- (void)scanForRemoteSensor
{
    BOOL centralManagerIsReady = NO;
    while (!centralManagerIsReady) {
        switch (centralManager.state) {
            case CBCentralManagerStateResetting:
                NSLog(@"Resetting connection");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStateUnsupported:
                NSLog(@"Device unsupport");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStateUnauthorized:
                NSLog(@"Unauthorized to use BLE");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@"Bluetooth is off");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStatePoweredOn:
                NSLog(@"Bluetooth is on");
                centralManagerIsReady = YES;
                break;
                
            default:
                NSLog(@"Unknown error occured");
                centralManagerIsReady = NO;
                break;
        }
    }
    
    if (centralManagerIsReady) {
        [self scanForPeripherals];
    }
}

- (void)disconnectFromRemoteSensor
{
    [m_peripheral writeValue:stopByte forCharacteristic:command_characteristic type:CBCharacteristicWriteWithResponse];
    [self disconnectPeripheral:m_peripheral];
}

- (void)scanForPeripherals
{
    [centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:TPHEMGSensorServiceUUID] options:nil];
    NSLog(@"Start scanning");
    [[self delegate] TPHEMGSensorDidUpdateStatusMessage:@"Scanning for remote sensor..."];
    TPHEMGSensorStateStopScanning = NO;
    TPHEMGSensorStateScanning = YES;
    [[self delegate] TPHEMGSensorDidUpdateState];
}

- (void)stopScanForPerpherals
{
    [centralManager stopScan];
    NSLog(@"Scaning stopped");
    [[self delegate] TPHEMGSensorDidUpdateStatusMessage:@"Stop scanning for remote sensor"];
    TPHEMGSensorStateStopScanning = YES;
    TPHEMGSensorStateScanning = NO;
    [[self delegate] TPHEMGSensorDidUpdateState];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [centralManager connectPeripheral:peripheral options:nil];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@", peripheral.name);
    TPHEMGDeviceName = peripheral.name;
    [[self delegate] TPHEMGSensorDidUpdateStatusMessage:[NSString stringWithFormat:@"Discovered %@", peripheral.name]];
    
    TPHEMGSensorStateDiscovered = YES;
    [[self delegate] TPHEMGSensorDidUpdateState];
    
    m_peripheral = peripheral;
    [centralManager connectPeripheral:m_peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Encounter %@", [error localizedDescription]);
    }
    NSLog(@"Disconnected %@", peripheral.name);
    [[self delegate] TPHEMGSensorDidUpdateStatusMessage:[NSString stringWithFormat:@"Disconnected from %@", peripheral.name]];
    _connectionState = NO;
    [[self delegate] TPHEMGSensorDidUpdateConnectionState:_connectionState];
    
    TPHEMGSensorStateDisconnected = YES;
    TPHEMGSensorStateConnected = NO;
    TPHEMGSensorStateListening = NO;
    TPHEMGSensorStateTransmitting = NO;
    TPHEMGSensorStateDiscovered = NO;
    [[self delegate] TPHEMGSensorDidUpdateState];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (CBCentralManagerStatePoweredOn) {
        NSLog(@"centralManager is on");
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"%@ connected", peripheral.name);
    _connectionState = YES;
    [[self delegate] TPHEMGSensorDidUpdateConnectionState:_connectionState];
    [[self delegate] TPHEMGSensorDidUpdateStatusMessage:[NSString stringWithFormat:@"Connected with %@", peripheral.name]];
    [self stopScanForPerpherals];
    
    TPHEMGSensorStateDisconnected = NO;
    TPHEMGSensorStateConnected = YES;
    [[self delegate] TPHEMGSensorDidUpdateState];
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error during services discovery: %@", [error localizedDescription]);
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:TPHControlServiceUUID]) {
            NSLog(@"%@ service discovered", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error during characteristics discovery for %@: %@", service.UUID, [error localizedDescription]);
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:TPHEMGSignalCharacteristicUUID]) {
            NSLog(@"Discovered characteristic %@", characteristic.UUID);
            emg_characteristic = characteristic;
            [m_peripheral setNotifyValue:YES forCharacteristic:emg_characteristic];
            [[self delegate] TPHEMGSensorDidUpdateStatusMessage:@"Listening for signal"];
            TPHEMGSensorStateListening = YES;
            [[self delegate] TPHEMGSensorDidUpdateState];
        }
        if ([characteristic.UUID isEqual:TPHADCSettingCharacteristicUUID]) {
            NSLog(@"Discovered characteristic %@", characteristic.UUID);
            setting_characteristic = characteristic;
            [m_peripheral setNotifyValue:YES forCharacteristic:setting_characteristic];
        }
        if ([characteristic.UUID isEqual:TPHCommandCharacteristicUUID]) {
            NSLog(@"Discovered characteristic %@", characteristic.UUID);
            command_characteristic = characteristic;
            //[m_peripheral readValueForCharacteristic:command_characteristic];
            [m_peripheral writeValue:startByte forCharacteristic:command_characteristic type:CBCharacteristicWriteWithResponse];
            [[self delegate] TPHEMGSensorDidUpdateStatusMessage:@"Telling sensor to start transmitting signal"];
            TPHEMGSensorStateTransmitting = YES;
            [[self delegate] TPHEMGSensorDidUpdateState];
        }
        [NSThread sleepForTimeInterval:3];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error when characteristic's value is updated: %@", [error localizedDescription]);
    }
    if ([characteristic.UUID isEqual:TPHEMGSignalCharacteristicUUID]) {
        NSData *data = characteristic.value;
        TPHData *signal = [[TPHData alloc] initWithRawData:data];
        [[self delegate] TPHEMGSensorDidReceiveDataFromRemoteSensor:signal];
        data = nil;
    } else if ([characteristic.UUID isEqual:TPHADCSettingCharacteristicUUID]) {
        ADCSettingByte = characteristic.value;
        [self decodeADCSetting];
        [[self delegate] TPHEMGSensorDidUpdateADCSetting:ADCSettingByte];
//        NSLog(@"%@", ADCSettingByte);
        NSMutableData *test = [NSMutableData dataWithData:ADCSettingByte];
        if ([self verifyADCSetting:test]) {
            NSLog(@"Valid");
        } else {
            NSLog(@"Invalid");
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //[peripheral readValueForCharacteristic:characteristic];
    if (error) {
        NSLog(@"Error write value for characterist %@ %@", characteristic.UUID, [error localizedDescription]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Update notification");
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    } else {
        if ([characteristic.UUID isEqual:TPHADCSettingCharacteristicUUID]) {
            [self requestADCSettingInformation];
        }
    }
}

- (void)requestADCSettingInformation
{
    [m_peripheral writeValue:ADCByte forCharacteristic:command_characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)decodeADCSetting
{
    NSMutableArray *rawByte = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 14; i++) {
        [rawByte addObject:[ADCSettingByte subdataWithRange:NSMakeRange(i, 1)]];
    }
    
    sensorGain1 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:0] bytes]);
    sensorGain2 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:2] bytes]);
    sensorGain3 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:4] bytes]);
    sensorGain4 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:6] bytes]);
    sensorGain5 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:8] bytes]);
    sensorGain6 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:10] bytes]);
    
    sensorOverSample1 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:1] bytes]);
    sensorOverSample2 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:3] bytes]);
    sensorOverSample3 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:5] bytes]);
    sensorOverSample4 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:7] bytes]);
    sensorOverSample5 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:9] bytes]);
    sensorOverSample6 = CFSwapInt16LittleToHost(*(int*)[[rawByte objectAtIndex:11] bytes]);
    
//    NSLog(@"%d %d %d %d %d %d %d %d %d %d %d %d ", sensorGain1, sensorGain2, sensorGain3, sensorGain4, sensorGain5, sensorGain6, sensorOverSample1, sensorOverSample2, sensorOverSample3, sensorOverSample4, sensorOverSample5, sensorOverSample6);
}

- (BOOL)verifyADCSetting:(NSMutableData *)data
{
    int dataSize = 14;
    //NSLog(@"%@", data);
    if (data.length < dataSize) {
        return NO;
    } else {
        if (data.length > dataSize) {
            [data setLength:(NSUInteger)dataSize];
        }
        NSData *checksum = [data subdataWithRange:NSMakeRange(dataSize - 1, 1)];
        NSData *body = [data subdataWithRange:NSMakeRange(1, dataSize - 2)];

        NSData *sum = [NSData dataWithBytes:"\00" length:1];
        for (int i = 0; i < body.length; i++) {
            sum = [self XOR:sum with:[body subdataWithRange:NSMakeRange(i, 1)]];
        }
        NSLog(@"Data:%@ Body:%@ Checksum:%@ Sum:%@", data, body, checksum, sum);
        if ([sum isEqualToData:checksum]) {
            return YES;
        } else {
            return NO;
        }
    }
}

-(NSData *) XOR:(NSData *)data1 with:(NSData *)data2
{
    const char *bytes1 = [data1 bytes];
    const char *bytes2 = [data2 bytes];
    
    NSMutableData *result = [[NSMutableData alloc] init];
    for (int i = 0; i < data1.length; i++){
        const char xorByte = bytes1[i] ^ bytes2[i];
        [result appendBytes:&xorByte length:1];
    }
    return result;
}


- (void)setSensor:(int8_t)sensorNumber gainLevelTo:(int8_t)level
{
    NSData *sensor = [NSData dataWithBytes:&sensorNumber length:sizeof(sensorNumber)];
    NSData *gainLevel = [NSData dataWithBytes:&level length:sizeof(level)];
    
    NSMutableData *command = [NSMutableData dataWithBytes:"\xF4" length:1];
    [command appendData:sensor];
    [command appendData:gainLevel];
    
//    NSLog(@"%@", command);
    
    [m_peripheral writeValue:command forCharacteristic:command_characteristic type:CBCharacteristicWriteWithResponse];
    [self requestADCSettingInformation];
}

- (void)setSensor:(int8_t)sensorNumber overSampleLevelTo:(int8_t)level
{
    NSData *sensor = [NSData dataWithBytes:&sensorNumber length:sizeof(sensorNumber)];
    NSData *overSampleLevel = [NSData dataWithBytes:&level length:sizeof(level)];
    
    NSMutableData *command = [NSMutableData dataWithBytes:"\xF5" length:1];
    [command appendData:sensor];
    [command appendData:overSampleLevel];
    
    //    NSLog(@"%@", command);
    
    [m_peripheral writeValue:command forCharacteristic:command_characteristic type:CBCharacteristicWriteWithResponse];
    [self requestADCSettingInformation];
}

@end
