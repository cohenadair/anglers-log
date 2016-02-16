//
//  CrittercismConfig.h
//  Crittercism-iOS
//
//  Created by David Shirley 2 on 1/8/15.
//  Copyright (c) 2015 Crittercism. All rights reserved.
//
//  This object is used to specify various configuration options to Crittercism.
//  Once this object is setup, you can pass it to [Crittercism enableWithAppID].
//  After Crittercism is initialized, changes to this object will have no affect.

#import <Foundation/Foundation.h>
#import "CrittercismDelegate.h"
#import "CrittercismLoggingLevel.h"

@interface CrittercismConfig : NSObject

// Determines whether Service Monitoring should capture network performance
// information for network calls made through NSURLConnection.
// Default value: YES
@property (nonatomic, assign) BOOL monitorNSURLConnection;

// Determines whether Service Monitoring should capture network performance
// information for network calls made through NSURLSession.
// Default value: YES
@property (nonatomic, assign) BOOL monitorNSURLSession;

// Determine whether Service Monitoring should capture network performance
// information for network calls made through a UIWebView or WKWebView. Currently
// only page loads and page transitions are captured. Calls made via javascript
// are currently not captured.
//

// UIWebView and WKWebView monitoring are disabled on tvOS
// The default value is "disabled" because use of the UIWebView or WKWebView
// class has the side effect of calling [UIWebView initialize] or
// [WKWebView initialize], both of which create new threads to manage webviews.
// Since Crittercism cannot prevent these side effects from happening and many
// apps do not use webviews, service monitoring for webviews must be explicitly
// enabled.
//
// Default value: NO
@property (nonatomic, assign) BOOL monitorUIWebView;
// Default value: NO
@property (nonatomic, assign) BOOL monitorWKWebView;

// Watch Connectivity Service Monitoring is disabled on tvOS
// Determines whether Service Monitoring should monitor Watch Connectivity
// two-way communications conduit between an iOS app and a WatchKit extension
// on a paired Apple Watch.
// Default value: YES
@property (nonatomic, assign) BOOL monitorWCSession;

// This flag determines wither Crittercism service monitoring is enabled at all.
// If this flag is set to NO, then no instrumentation will be installed AND
// the thread that sends service monitoring data will be disabled.
// Default value: YES (enabled)
@property (nonatomic, assign) BOOL enableServiceMonitoring;

// Determines whether Crittercism should automatically send app load request or
// the app will decide when app load request should be sent by calling sendAppLoadData.
// Default value: NO (Crittercism will automatically send app load request)
@property (nonatomic, assign) BOOL delaySendingAppLoad;

// This flag determines the verbosity of Crittercism log messages
@property (nonatomic, assign) CRLoggingLevel loggingLevel DEPRECATED_MSG_ATTRIBUTE("Use [Crittercism setLoggingLevel:] instead");

// An array of CRFilter objects. These filters are used to make it so certain
// network performance information is not reported to Crittercism, for example
// URLs that may contain sensitive information. These filters can also be used
// to prevent URL query parameters from being stripped out (by default all query
// parameters are removed before being sent to Crittercism).
@property (nonatomic, strong) NSArray *urlFilters;

// This object provides a callback that Crittercism will use to notify an app
// that the app crashed on the last load.
@property (nonatomic, strong) id<CrittercismDelegate> delegate;

// Creates a new CrittercismConfig object with the default values for the above
// properties. You can modify the config values and pass this object into
// [Crittercism enableWithAppID:andConfig]
+ (CrittercismConfig *)defaultConfig;

- (NSString *)description;

@end
