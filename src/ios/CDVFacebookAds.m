
#import "CDVFacebookAds.h"

@interface CDVFacebookAds()

@property(nonatomic, retain) CordovaFBAN* _AdsApi;

@end

@implementation CDVFacebookAds
@synthesize _AdsApi;

- (UIView*) getView {
    return self.webView;
}

- (UIViewController*) getViewController {
    return self.viewController;
}

- (void) onEvent:(NSString *)eventType withData:(NSString *)jsonString {
    NSLog(@"%@, %@", eventType, jsonString?jsonString:@"");
    NSString * js = nil;
    if(jsonString != nil) {
        js = [NSString stringWithFormat:@"cordova.fireDocumentEvent('%@', %@ );", eventType, jsonString];
    } else {
        js = [NSString stringWithFormat:@"cordova.fireDocumentEvent('%@');", eventType];
    }
    [self.commandDelegate evalJs:js];
}

- (void) evalJs:(NSString*) js
{
    [self.commandDelegate evalJs:js];
}

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView {
	self = (CDVFacebookAds *)[super initWithWebView:theWebView];
	if (self) {
        _AdsApi = [[CordovaFBAN alloc] init:self];
	}
    
	return self;
}

- (void) setOptions:(CDVInvokedUrlCommand *)command {
    NSLog(@"setOptions");
    
    if([command.arguments count] > 0) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [_AdsApi setOptions:options];
    }
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}


- (void)createBanner:(CDVInvokedUrlCommand *)command {
    NSLog(@"createBanner");

    if([command.arguments count] > 0) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        if([options count] > 1) {
            [_AdsApi setOptions:options];
        }
        
        NSString* adId = [options objectForKey:@"adId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_AdsApi createBanner:adId];
        });
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];

    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"bannerId needed"] callbackId:command.callbackId];
    }
}

- (void)removeBanner:(CDVInvokedUrlCommand *)command {
    NSLog(@"removeBanner");

    [_AdsApi removeBanner];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) showBanner:(CDVInvokedUrlCommand *)command {
    
    int position = [[command argumentAtIndex:0 withDefault:@"2"] intValue];
    
    NSLog(@"showBanner:%d", position);
    
    [_AdsApi showBanner:position];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) showBannerAtXY:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command argumentAtIndex:0];
    int x = (int)[params integerValueForKey:@"x" defaultValue:0];
    int y = (int)[params integerValueForKey:@"y" defaultValue:0];
    [_AdsApi showBannerAtX:x withY:y];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) hideBanner:(CDVInvokedUrlCommand *)command {
    NSLog(@"hideBanner");
    
    [_AdsApi hideBanner];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) prepareInterstitial:(CDVInvokedUrlCommand *)command {
    NSLog(@"prepareInterstitial");
    
    if([command.arguments count] > 0) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        if([options count] > 1) {
            [_AdsApi setOptions:options];
        }
        
        NSString* adId = [options objectForKey:@"adId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_AdsApi prepareInterstitial:adId];
        });
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
        
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interstitialId needed"] callbackId:command.callbackId];
    }
}

- (void) showInterstitial:(CDVInvokedUrlCommand *)command
{
    NSLog(@"showInterstitial");
    
    [_AdsApi showInterstitial];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

@end
