//
//  LWConstants.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 24.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 List of Proxima Fonts
 ProximaNova-Semibold
 ProximaNova-Regular
 ProximaNova-Light
 ProximaNova-Bold
 */


#pragma mark - Server Constants
//#define kDevelopTestServer @"lykke-api-dev.azurewebsites.net"

#define kProductionServer  @"api.lykke.com"
#define kStagingTestServer @"api-staging.lykke.com"
#define kDevelopTestServer @"api-dev.lykkex.net"
#define kTestingTestServer @"api-test.lykkex.net"

#define kBlueProductionServer  @"blue-api.lykke.com"
#define kBlueStagingTestServer @"blue-api-staging.lykke.com"
#define kBlueDevelopTestServer @"blue-api-dev.lykkex.net"
#define kBlueTestingTestServer @"blue-api-test.lykkex.net"

#pragma mark - General Constants

#define kFontBold @"ProximaNova-Bold"
#define kFontLight @"ProximaNova-Light"
#define kFontRegular @"ProximaNova-Regular"
#define kFontSemibold @"ProximaNova-Semibold"

#define kMainElementsColor @"AB00FF"
#define kMainWhiteElementsColor @"FFFFFF"
#define kMainDarkElementsColor @"3F4D60"
#define kMainGrayElementsColor @"EAEDEF"

#define kAssetEnabledItemColor  @"AB00FF"
#define kAssetDisabledItemColor @"3F4D60"

#define kErrorTextColor         @"FF2E2E"

#define kMaxImageServerSize  1980
#define kMaxImageServerBytes 5000000

#pragma mark - ABPadView

static NSString *const kABPadBorderColor   = @"D3D6DB";
static NSString *const kABPadSelectedColor = @"AB00FF";


#pragma mark - Label Constants

static NSString *const kLabelFontColor = kMainDarkElementsColor;


#pragma mark - Button Constants

static float     const kButtonFontSize  = 15.0;
static NSString *const kButtonFontName  = kFontSemibold;
static NSString *const kDisabledButtonFontColor = @"D6D6D6";
static NSString *const kEnabledButtonFontColor = @"FFFFFF";
static NSString *const kSellAssetButtonColor = @"FF3E2E";


#pragma mark - Text Field Constants

#define kDefaultLeftTextFieldOffset  20
#define kDefaultRigthTextFieldOffset 20
#define kDefaultTextFieldPlaceholder @"AB00FF"
static float     const kTextFieldFontSize  = 17.0;
static NSString *const kTextFieldFontColor = kMainDarkElementsColor;
static NSString *const kTextFieldFontName  = kFontRegular;


#pragma mark - Tab Bar Constants

static NSString *const kTabBarBackgroundColor   = @"FFFFFF";
static NSString *const kTabBarTintColor         = @"D3D6DB";
static NSString *const kTabBarSelectedTintColor = @"AB00FF";


#pragma mark - Navigation Bar Constants

static NSString *const kNavigationTintColor     = @"FFFFFF";
//static NSString *const kNavigationBarTintColor  = @"AB00FF";
static NSString *const kNavigationBarTintColor  = @"0DA7FC"; //Lykke 2.0

static NSString *const kNavigationBarGrayColor  = kMainGrayElementsColor;
static NSString *const kNavigationBarWhiteColor = kMainWhiteElementsColor;

static float     const kNavigationBarFontSize   = 17.0;
static NSString *const kNavigationBarFontColor  = kMainDarkElementsColor;
static NSString *const kNavigationBarFontName   = kFontSemibold;

static float     const kModalNavBarFontSize     = 15.0;
static NSString *const kModalNavBarFontName     = kFontRegular;


#pragma mark - Page Control Constants

static NSString *const kPageControlDotColor       = @"D3D6DB";
static NSString *const kPageControlActiveDotColor = @"AB00FF";


#pragma mark - Asset Colors

static float     const kAssetDetailsFontSize      = 17.0;
static NSString *const kAssetChangePlusColor      = @"53AA00";
static NSString *const kAssetChangeMinusColor     = @"FF2E2E";


#pragma mark - Table Cells

static float     const kTableCellDetailFontSize   = 22.0;
static NSString *const kTableCellLightFontName    = kFontLight;
static NSString *const kTableCellRegularFontName  = kFontRegular;

static float     const kTableCellTransferFontSize = 15.0;

