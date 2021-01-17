//
//  MigrationChannel.m
//  Runner
//
//  Created by Cohen Adair on 2021-01-11.
//  Copyright © 2021 Anglers' Log. All rights reserved.
//

#import <Flutter/Flutter.h>

#import "AppDelegate.h"
#import "CMAJSONWriter.h"
#import "CMAStorageManager.h"
#import "MigrationChannel.h"

#define CHANNEL_NAME @"com.cohenadair.anglerslog/migration"
#define EXPORT_NAME @"legacyJson"

@implementation MigrationChannel

+ (void)create:(AppDelegate *)appDelegate {
    FlutterViewController *controller =
            (FlutterViewController *) appDelegate.window.rootViewController;
    
    FlutterMethodChannel *channel =
            [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                        binaryMessenger:controller.binaryMessenger];

    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([EXPORT_NAME isEqualToString:call.method]) {
            [MigrationChannel legacyJson:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

+ (void)legacyJson:(FlutterResult)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *json;
            // Returns false if there is no data to load (i.e. it's a fresh install).
            if ([[CMAStorageManager sharedManager] loadJournal]) {
                CMAJournal *journal = [CMAStorageManager sharedManager].sharedJournal;
                json = [CMAJSONWriter journalToJSON:journal];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                result(json);
            });
        } @catch (NSException *e) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                result([FlutterError errorWithCode:@"E" message:e.debugDescription details:nil]);
            });
        }
    });
}

@end
