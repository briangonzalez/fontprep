//
//  AppDelegate.h
//  fontprep
//
//  Created by Brian M. Gonzalez.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

extern NSString *const FONTPREP_PORT;
extern NSString *const FONTPREP_HOST;
extern NSString *const FONTPREP_URL;


@interface AppDelegate : NSObject <NSApplicationDelegate>{
  NSString *ready;
  @private int fxServerTask1;
}

@property (nonatomic, retain) NSTask              *fxServerTask;
@property (assign) IBOutlet NSWindow              *splash;
@property (assign) IBOutlet NSWindow              *window;
@property (assign) IBOutlet WebView               *webview;
@property (assign) IBOutlet NSProgressIndicator   *progress;
@property (nonatomic, retain) NSString            *serverVersion;
@property (nonatomic, retain) NSString            *resourcePath;
@property (nonatomic, retain) NSString            *systemRubyPath;
@property (nonatomic, retain) NSString            *versionString;
@property (nonatomic, assign) BOOL                *versionsInSync;
@property (nonatomic, retain) NSString            *currentVersion;
@property (nonatomic, retain) NSTimer             *pingTimer;
@property (nonatomic, retain) NSTimer             *longRunningTimer;
@property (nonatomic, retain) NSTimer             *alertTimer;

@end
