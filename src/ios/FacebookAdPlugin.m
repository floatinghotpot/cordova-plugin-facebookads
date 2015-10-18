//
//  FacebookAdPlugin.m
//  TestAdMobCombo
//
//  Created by Xie Liming on 14-11-8.
//
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "UITapGestureRecognizer+Spec.h"
#import "FacebookAdPlugin.h"

#define TEST_BANNER_ID           @"726719434140206_777151452430337"
#define TEST_INERSTITIAL_ID      @"726719434140206_777151589096990"
#define TEST_NATIVE_ID           @"726719434140206_777151705763645"

#define OPT_DEVICE_HASH          @"deviceHash"

@interface FacebookAdPlugin()<FBAdViewDelegate, FBInterstitialAdDelegate, FBNativeAdDelegate, UIGestureRecognizerDelegate>

@property (assign) FBAdSize adSize;
@property (nonatomic, retain) NSMutableDictionary* nativeads;

- (void) __removeNativeAd:(NSString*)adId;
- (void) fireNativeAdLoadEvent:(FBNativeAd*)nativeAd;

@end


// ------------------------------------------------------------------

@interface UITrackingView : UIView

@end

@implementation UITrackingView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // Always ignore the touch event, so that we can scroll the webview beneath.
    // We will inovke GestureRecognizer callback ourselves.
    return nil;
}
@end

// ------------------------------------------------------------------

@interface FlexNativeAd : NSObject

@property (nonatomic, retain) NSString* adId;
@property (nonatomic, retain) FBNativeAd* ad;
@property (nonatomic, retain) UITrackingView* view;
@property (assign) int x,y,w,h;

- (FlexNativeAd*) init;

@end

@implementation FlexNativeAd

- (FlexNativeAd*) init
{
    self.adId = NULL;
    self.ad = NULL;
    self.view = NULL;
    self.x = 0;
    self.y = 0;
    self.w = 0;
    self.h = 0;
    
    return self;
}

@end

// ------------------------------------------------------------------

@implementation FacebookAdPlugin

- (void)pluginInitialize
{
    [super pluginInitialize];
    
    self.adSize = [self __AdSizeFromString:@"SMART_BANNER"];
    self.nativeads = [[NSMutableDictionary alloc] init];
}

- (NSString*) __getProductShortName{
    return @"FacebookAds";
}

- (NSString*) __getTestBannerId;
{
    return TEST_BANNER_ID;
}

- (NSString*) __getTestInterstitialId
{
    return TEST_INERSTITIAL_ID;
}

- (FBAdSize) __AdSizeFromString:(NSString*)str
{
    FBAdSize sz;
    if ([str isEqualToString:@"BANNER"]) {
        sz = kFBAdSize320x50;
    // other size not supported by facebook audience network: FULL_BANNER, MEDIUM_RECTANGLE, LEADERBOARD, SKYSCRAPER
    //} else if ([str isEqualToString:@"SMART_BANNER"]) {
    } else {
        BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        sz = isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    }
    
    return sz;
}

- (void) parseOptions:(NSDictionary *)options
{
    [super parseOptions:options];
    
    NSString* str = [options objectForKey:OPT_AD_SIZE];
    if(str) {
        self.adSize = [self __AdSizeFromString:str];
    }
    
    if(self.isTesting) {
        self.testTraffic = true;
        
        str = [options objectForKey:OPT_DEVICE_HASH];
        if(str && [str length]>0) {
            NSLog(@"set device hash: %@", str);
            [FBAdSettings addTestDevice:str];
        }
        
        // TODO: add device hash, but know how to get the FB hash id on ios ...
    }
}


- (UIView*) __createAdView:(NSString*)adId
{
    FBAdView* ad = [[FBAdView alloc] initWithPlacementID:adId
                                                  adSize:self.adSize
                                      rootViewController:[self getViewController]];
    ad.delegate= self;
    
    if(self.adSize.size.height == 50 || self.adSize.size.height == 90) {
        ad.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleLeftMargin|
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleTopMargin;
    }
    
    return ad;
}

- (int) __getAdViewWidth:(UIView*)view
{
    return view.frame.size.width;
}

- (int) __getAdViewHeight:(UIView*)view
{
    return view.frame.size.height;
}

- (void) __loadAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        FBAdView* ad = (FBAdView*) view;
        [ad loadAd];
    }
}

- (void) __pauseAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        //FBAdView* ad = (FBAdView*) view;
        // [ad pause];
    }
}

- (void) __resumeAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        //FBAdView* ad = (FBAdView*) view;
        // [ad resume];
    }
}

- (void) __destroyAdView:(UIView*)view
{
    if([view isKindOfClass:[FBAdView class]]) {
        FBAdView* ad = (FBAdView*) view;
        ad.delegate = nil;
    }
}

- (NSObject*) __createInterstitial:(NSString*)adId
{
    FBInterstitialAd* ad = [[FBInterstitialAd alloc] initWithPlacementID:adId];
    ad.delegate = self;
    
    return ad;
}

- (void) __loadInterstitial:(NSObject*)interstitial
{
    if([interstitial isKindOfClass:[FBInterstitialAd class]]) {
        FBInterstitialAd* ad = (FBInterstitialAd*) interstitial;
        [ad loadAd];
    }
}

- (void) __showInterstitial:(NSObject*)interstitial
{
    if([interstitial isKindOfClass:[FBInterstitialAd class]]) {
        FBInterstitialAd* ad = (FBInterstitialAd*) interstitial;
        if(ad && ad.isAdValid) {
            [ad showAdFromRootViewController:[self getViewController]];
        }
    }
}

- (void) __destroyInterstitial:(NSObject*)interstitial
{
    if([interstitial isKindOfClass:[FBInterstitialAd class]]) {
        FBInterstitialAd* ad = (FBInterstitialAd*) interstitial;
        ad.delegate = nil;
    }
}

- (void)handleTapOnWebView:(UITapGestureRecognizer *)sender
{
    //NSLog(@"handleTapOnWeb");

    for(id key in self.nativeads) {
        FlexNativeAd* unit = (FlexNativeAd*) [self.nativeads objectForKey:key];
        CGPoint point = [sender locationInView:unit.view];
        if([unit.view pointInside:point withEvent:nil]) {
            NSLog(@"Native Ad view area tapped");

            NSArray* handlers = [unit.view gestureRecognizers];
            for(id handler in handlers) {
                if([handler isKindOfClass:[UITapGestureRecognizer class]]) {
                    UITapGestureRecognizer* tapHandler = (UITapGestureRecognizer*) handler;

                    // Here we call the injected method, defined in "UITapGestureRecognizer+Spec.m"
                    if([tapHandler respondsToSelector:@selector(performTapWithView:andPoint:)]) {
                        [tapHandler performTapWithView:unit.view andPoint:point];
                    }
                }
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)createNativeAd:(CDVInvokedUrlCommand *)command
{
    NSLog(@"createNativeAd");
    
    if([command.arguments count] >= 1) {
        NSString* adId = [command argumentAtIndex:0];
        
        if(self.testTraffic) adId = TEST_INERSTITIAL_ID;
        
        FlexNativeAd* unit = [self.nativeads objectForKey:adId];
        if(unit) {
            if(unit.adId) {
                [self __removeNativeAd:unit.adId];
            }
        }
        
        unit = [[FlexNativeAd alloc] init];
        unit.adId = adId;
        
        CGRect adRect = {{0,0},{0,0}};
        unit.view = [[UITrackingView alloc] initWithFrame:adRect];
        [[self getView] addSubview:unit.view];
        
        // add tap handler to handle tap on webview
        UITapGestureRecognizer *webViewTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnWebView:)];
        webViewTapped.numberOfTapsRequired = 1;
        webViewTapped.delegate = self;
        [[self getView] addGestureRecognizer:webViewTapped];

        if(self.isTesting) {
            [unit.view setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.2f]];
        }
        
        unit.ad = [[FBNativeAd alloc] initWithPlacementID:adId];
        unit.ad.delegate = self;
        
        [self.nativeads setObject:unit forKey:adId];
        
        [unit.ad loadAd];
        
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] to:command.callbackId];
    } else {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"] to:command.callbackId];
    }
}

- (void) __removeNativeAd:(NSString*)adId
{
    FlexNativeAd* unit = [self.nativeads objectForKey:adId];
    if(unit) {
        [self.nativeads removeObjectForKey:adId];
        
        if(unit.view) {
            CGRect adFrame = {{0,0},{0,0}};
            unit.view.frame = adFrame;
            [unit.view removeFromSuperview];
        }
        
        if(unit.ad) {
            [unit.ad unregisterView];
        }
    }
}

- (void)removeNativeAd:(CDVInvokedUrlCommand *)command
{
    NSLog(@"removeNativeAd");
    
    if([command.arguments count] >= 1) {
        NSString* adId = [command argumentAtIndex:0];
        [self __removeNativeAd:adId];
        
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] to:command.callbackId];
    } else {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"] to:command.callbackId];
    }
}

- (void)setNativeAdClickArea:(CDVInvokedUrlCommand *)command
{
    NSLog(@"setNativeAdClickArea");
    
    if([command.arguments count] >= 5) {
        NSString* adId = [command argumentAtIndex:0];
        
        FlexNativeAd* unit = [self.nativeads objectForKey:adId];
        if(unit && unit.view) {
            int x = [[command argumentAtIndex:1 withDefault:@"0"] intValue];
            int y = [[command argumentAtIndex:2 withDefault:@"0"] intValue];
            int w = [[command argumentAtIndex:3 withDefault:@"0"] intValue];
            int h = [[command argumentAtIndex:4 withDefault:@"0"] intValue];
            
            CGRect adRect = {{x,y},{w,h}};
            unit.view.frame = adRect;
            
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] to:command.callbackId];
            
        } else {
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"native ad not exists"] to:command.callbackId];
        }
        
    } else {
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid arguments"] to:command.callbackId];
    }
}

#pragma mark FBAdViewDelegate implementation

/**
 * document.addEventListener('onAdLoaded', function(data));
 * document.addEventListener('onAdFailLoad', function(data));
 * document.addEventListener('onAdPresent', function(data));
 * document.addEventListener('onAdDismiss', function(data));
 * document.addEventListener('onAdLeaveApp', function(data));
 */
- (void)adViewDidClick:(FBAdView *)adView
{
    [self fireAdEvent:EVENT_AD_LEAVEAPP withType:ADTYPE_BANNER];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    [self fireAdEvent:EVENT_AD_DISMISS withType:ADTYPE_BANNER];
}

- (void)adViewDidLoad:(FBAdView *)adView
{
    if((! self.bannerVisible) && self.autoShowBanner) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self __showBanner:self.adPosition atX:self.posX atY:self.posY];
        });
    }
    
    [self fireEvent:[self __getProductShortName] event:@"onBannerReceive" withData:NULL];
    
    [self fireAdEvent:EVENT_AD_LOADED withType:ADTYPE_BANNER];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD withCode:(int)error.code withMsg:[error localizedDescription] withType:ADTYPE_BANNER];
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    [self fireAdEvent:EVENT_AD_PRESENT withType:ADTYPE_BANNER];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FBInterstitialAdDelegate

/**
 * document.addEventListener('onAdLoaded', function(data));
 * document.addEventListener('onAdFailLoad', function(data));
 * document.addEventListener('onAdPresent', function(data));
 * document.addEventListener('onAdDismiss', function(data));
 * document.addEventListener('onAdLeaveApp', function(data));
 */
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    if (self.interstitial && self.autoShowInterstitial) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self __showInterstitial:self.interstitial];
        });
    }
    
    [self fireAdEvent:EVENT_AD_LOADED withType:ADTYPE_INTERSTITIAL];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD withCode:(int)error.code withMsg:[error localizedDescription] withType:ADTYPE_INTERSTITIAL];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    [self fireAdEvent:EVENT_AD_LEAVEAPP withType:ADTYPE_INTERSTITIAL];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    [self fireAdEvent:EVENT_AD_DISMISS withType:ADTYPE_INTERSTITIAL];
    
    if(self.interstitial) {
        [self __destroyInterstitial:self.interstitial];
        self.interstitial = nil;
    }
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
    [self fireAdEvent:EVENT_AD_WILLDISMISS withType:ADTYPE_INTERSTITIAL];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{
    [self fireAdEvent:EVENT_AD_WILLPRESENT withType:ADTYPE_INTERSTITIAL];
}

/**
 * document.addEventListener('onAdLoaded', function(data));
 * document.addEventListener('onAdFailLoad', function(data));
 * document.addEventListener('onAdPresent', function(data));
 * document.addEventListener('onAdDismiss', function(data));
 * document.addEventListener('onAdLeaveApp', function(data));
 */
- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD withCode:(int)error.code withMsg:[error localizedDescription] withType:ADTYPE_NATIVE];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    [self fireAdEvent:EVENT_AD_LEAVEAPP withType:ADTYPE_NATIVE];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
    [self fireAdEvent:EVENT_AD_DISMISS withType:ADTYPE_NATIVE];
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    [self fireNativeAdLoadEvent:nativeAd];
}

- (void) fireNativeAdLoadEvent:(FBNativeAd*)nativeAd
{
    [self.nativeads enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* adId = (NSString*) key;
        FlexNativeAd* unit = (FlexNativeAd*) obj;
        if(unit && unit.ad == nativeAd) {
            NSString *titleForAd = nativeAd.title;
            NSString *bodyTextForAd = nativeAd.body;
            FBAdImage *coverImage = nativeAd.coverImage;
            FBAdImage *iconForAd = nativeAd.icon;
            NSString *socialContextForAd = nativeAd.socialContext;
            struct FBAdStarRating appRatingForAd = nativeAd.starRating;
            NSString *titleForAdButton = nativeAd.callToAction;
            
            NSMutableDictionary* coverInfo = [[NSMutableDictionary alloc] init];
            [coverInfo setValue:[coverImage.url absoluteString] forKey:@"url"];
            [coverInfo setValue:[NSNumber numberWithInt:coverImage.width] forKey:@"width"];
            [coverInfo setValue:[NSNumber numberWithInt:coverImage.height] forKey:@"height"];
            
            NSMutableDictionary* iconInfo = [[NSMutableDictionary alloc] init];
            [iconInfo setValue:[iconForAd.url absoluteString] forKey:@"url"];
            [iconInfo setValue:[NSNumber numberWithInt:iconForAd.width] forKey:@"width"];
            [iconInfo setValue:[NSNumber numberWithInt:iconForAd.height] forKey:@"height"];
            
            NSMutableDictionary* adRes = [[NSMutableDictionary alloc] init];
            [adRes setValue:coverInfo forKey:@"coverImage"];
            [adRes setValue:iconInfo forKey:@"icon"];
            [adRes setValue:titleForAd forKey:@"title"];
            [adRes setValue:bodyTextForAd forKey:@"body"];
            [adRes setValue:socialContextForAd forKey:@"socialContext"];
            [adRes setValue:[NSNumber numberWithFloat:appRatingForAd.value] forKey:@"rating"];
            [adRes setValue:[NSNumber numberWithInt:appRatingForAd.scale] forKey:@"ratingScale"];
            [adRes setValue:titleForAdButton forKey:@"buttonText"];
            
            NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
            [json setValue:[self __getProductShortName] forKey:@"adNetwork"];
            [json setValue:EVENT_AD_LOADED forKey:@"adEvent"];
            [json setValue:ADTYPE_NATIVE forKey:@"adType"];
            [json setValue:adId forKey:@"adId"];
            [json setValue:adRes forKey:@"adRes"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&err];
            NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [unit.ad registerViewForInteraction:unit.view withViewController:[self getViewController]];
            
            [self fireEvent:[self __getProductShortName] event:EVENT_AD_LOADED withData:jsonStr];
            
            *stop = YES;
        }
    }];
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    [self fireAdEvent:EVENT_AD_PRESENT withType:ADTYPE_NATIVE];
}

@end
