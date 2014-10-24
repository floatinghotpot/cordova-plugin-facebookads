#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CordovaFBAN.h"

#pragma mark FacebookAds Plugin

@interface CDVFacebookAds : CDVPlugin <AppContainerDelegate> {
}

- (void) setOptions:(CDVInvokedUrlCommand *)command;

- (void)createBanner:(CDVInvokedUrlCommand *)command;
- (void)showBanner:(CDVInvokedUrlCommand *)command;
- (void)showBannerAtXY:(CDVInvokedUrlCommand *)command;
- (void)hideBanner:(CDVInvokedUrlCommand *)command;
- (void)removeBanner:(CDVInvokedUrlCommand *)command;

- (void)prepareInterstitial:(CDVInvokedUrlCommand *)command;
- (void)showInterstitial:(CDVInvokedUrlCommand *)command;

@end
