//
//  File.swift
//  KNSWTemplate
//
//  Created by Peter van de Put on 24/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import Foundation
import UIKit


//MARK: App constant
let MAIN_SCREEN:UIScreen      = UIScreen.mainScreen()
let ScreenWidth:CGFloat       = MAIN_SCREEN.bounds.size.width
let ScreenHeight:CGFloat      = MAIN_SCREEN.bounds.size.height
let IsIphone4:Bool            = ScreenHeight == 480 ? true : false
let iOS7                      = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
let iOS8OrHigher              = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)

let kRegularFontName: String       = "HelveticaNeue"
let kLightFontName: String         = "HelveticaNeue-Light"
let kMediumFontName: String        = "HelveticaNeue-Medium"
let kBoldFontName: String          = "HelveticaNeue-Bold"
let kCondensedBoldFontName: String = "HelveticaNeue-CondensedBold"

let kBigFontSize: CGFloat     = 19.0
let kDefaultFontSize: CGFloat = 17.0
let kMediumFontSize: CGFloat  = 15.0
let kSmallFontSize: CGFloat   = 12.0

let kTextColor:UIColor                = UIColor.whiteColor()
let kNavigationTitleTintColor:UIColor = UIColor.whiteColor()
let kNavigationTitleFont:UIFont       = UIFont(name: kRegularFontName, size: kBigFontSize)!
let kNavigationItemBarTitleFont       = UIFont(name: kRegularFontName, size: kMediumFontSize)!

let kChangeStoryboardTimer: NSTimeInterval = 0.5

let kMediaDirectory:String = "Media"

// MARK - Caremera picker
let kNewAvatarImageName:String = "new_Selected_Image"

// MARK - S3 Amazon
let kS3BucketAccessKey:String = "AKIAIMBNZBMDEKDBBPNA"
let kS3BucketSecretKey:String = "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"
let kS3BucketName:String      = "tipper-avatar"

// MARK - Flurry
let kFlurryApiKey:String = "8YDFSKC2SM5DG74QBMBT"

// MARK - Google Anamytics
let kGoogleAnalyticsKey:String  = "UA-53851491-5"

//// MARK - api ulr
let kAPITestRoute:String                 = ""

//MARK: Main
let kMainStoryboardName: String = "Main"

//MARK: Splash module
let kSecondToDisplaySplash:NSTimeInterval                     = 2.0
let splashScreenWithEmailRatio:CGFloat                        = 0.22
let splashScreenWithLogoAndEmailRatio:CGFloat                 = 0.15
let splashScreenMarginTopWhenEditing:CGFloat                  = 90
let splashScreenMarginLogoAndEmailWhenEditing:CGFloat         = 5
let splashScreenMarginTopWhenEditingForIphone4:CGFloat        = 160
let splashScreenLogoHeightWhenEditingForIphone4:CGFloat       = 120
let splashScreenFontSizeTipperWhenEditingForIphone4:CGFloat   = 20
let splashScreenFontSizeSubTitleWhenEditingForIphone4:CGFloat = 12
let splashScreenMarginLogoInsideWhenEditingForIphone4:CGFloat = 5
let splashScreenFontSizeTipperDefault:CGFloat                 = 30
let splashScreenFontSizeSubTitleDefault:CGFloat               = 18
let splashScreenMarginLogoInsideDefault:CGFloat               = 20

//MARK: process flow
let kFirstTimeUse:String           = "kFirstTimeUse"
let kSegueNameAfterSplash:String   = "segueSplashToRoot"
let kSegueNameAfterFirstTimeLaunch = "sequeSplashToTutorial"
let kSegueSplashToCreateAccount    = "segueSplashToCreateAccount"

//MARK: Login Module
let kLoginStoryboardName: String = "KNLogin"

//MARK: Profile Module
let kProfileStoryboardName: String   = "KNProfile"
let kEditProfileStoryboardId: String = "kEditProfileStoryboardId"

//MARK: Account Module
let kAccountStoryboardName: String     = "KNAccount"
let kAccountCreateStoryboardId: String = "kAccountCreateStoryboardId"

//MARK: Tutorial
let kUseTutorial:Bool              = true
let kTutorialAlreadyShown:String   = "kTutorialAlreadyShown"
let kTutorialStoryboardName:String = "KNTutorial"

let kTutorialMasterPage:String = "KNTutorialMaster"

//MARK: KNReview
let kReviewStoryboardName: String = "KNReview"
let kReviewControllerName: String = "KNReviewPopupViewController1"
let kAppstoreAppId: String        = "909739254"
let kUseReviewModule              = true
let kInitialIntervalToAsk         = 5
let kSubsequentIntervalToAsk      = 3
let kHasBeenAskedAlready          = "kHasBeenAskedAlready"
let kInitialUsageCount            = "kInitialUsageCount"
let kSubsequentUsageCount         = "kSubsequentUsageCount"
let kStopAsking                   = "kStopAsking"

//MARK: KNSwipeMenu
let kApplicationStoryboardName: String = "Application"
let kApplicationMasterPage:String      = "ApplicationMasterPage"
let kMenuItemCellIdentifier:String     = "kMenuItemCellIdentifier"



let kActivityStoryboardId:String   = "kActivityStoryboardId"
let kStarredStoryboardId:String    = "kStarredStoryboardId"
let kSettingsStoryboardId:String   = "kSettingsStoryboardId"
let kFindPeopleStoryboardId:String = "kFindPeopleStoryboardId"
let kLogoutStoryboardId:String     = "kLogoutStoryboardId"

//MARK: Tipper Module
let kTipperStoryboardName: String        = "KNTipper"
let kAccessContactsViewController:String = "KNAccessContactsViewController"
let kMainViewController:String           = "KNMainViewController"

//MARK: Settings Module
let kSettingStoryboardName: String = "KNSettings"

//MARK: CardManagement
let kCardManagementStoryboardName: String = "KNCardManagement"
let kAddCardViewControllerId: String      = "KNAddCCViewController"
let kEditCardViewControllerId: String     = "KNEditCCViewController"
let kDeleteCardViewControllerId: String   = "KNDeleteCCViewController"

//MAKR - Edit Avatar
let kEditImageStoryboardName:String = "KNEditImage"
let kEditImageViewControllerId: String = "KNEditImageViewController"


//MARK: API communication
let  kBaseURL:String = "http://tipper-dev.knodeit.com"
let  kAPIStatusOk    = "ok"
let  kAPIStatusError = "error"
let kTempAccessToken = "f78464c7-2229-49d3-82f0-ac612c662503"


//MARK: Routes
let kAPIVersion: String              = "/api/v1"
let kAPICheckEmailExist: String      = kBaseURL + kAPIVersion + "/user/exist"
let kAPILogin: String                = kBaseURL + kAPIVersion + "/user/login"
let kAPILogout: String               = kBaseURL + kAPIVersion + "/user/logoff"
let kAPIRegister: String             = kBaseURL + kAPIVersion + "/user/registration/add"
let kAPIDeleteRegister: String       = kBaseURL + kAPIVersion + "/user/registration/delete"
let kAPISendCodeToPhone: String      = kBaseURL + kAPIVersion + "/user/mobile/verification/request"
let kAPIResendCodeToPhone: String    = kBaseURL + kAPIVersion + "/user/mobile/verification/resend"
let kAPIPhoneVerification: String    = kBaseURL + kAPIVersion + "/user/mobile/verification"
let kAPIGetProfile: String           = kBaseURL + kAPIVersion + "/user/profile/info"
let kAPIUpdateProfile: String        = kBaseURL + kAPIVersion + "/user/profile/update"
let kAPISetUpPinCode: String         = kBaseURL + kAPIVersion + "/user/profile/pincode"
let kAPICheckPinCode: String         = kBaseURL + kAPIVersion + "/user/profile/pincode/check"
let kAPIGetCurrentBlance: String     = kBaseURL + kAPIVersion + "/user/balance"
let kAPIBalanceTip: String           = kBaseURL + kAPIVersion + "/user/balance/tip"

let kAPISyncAddressBook: String      = kBaseURL + kAPIVersion + "/user/addressbook/sync"
let kAPIGetTaskId: String            = kBaseURL + kAPIVersion + "/user/friends/find"
let kAPITaskStatus: String           = kBaseURL + kAPIVersion + "/user/friends/find/status"
let kAPIGetListOfFriends: String     = kBaseURL + kAPIVersion + "/user/friends/list"
let kAPISearchFriends: String        = kBaseURL + kAPIVersion + "/user/friends/search"
let kAPIAddFriend: String            = kBaseURL + kAPIVersion + "/user/friends/add"

let kAPIListRegisteredCards: String  = kBaseURL + kAPIVersion + "/user/cards/charge/list"
let kAPIAddCard: String              = kBaseURL + kAPIVersion + "/user/cards/charge/add"
let kAPIDeleteCard: String           = kBaseURL + kAPIVersion + "/user/cards/charge/delete"
let kAPISetDefaultCard: String       = kBaseURL + kAPIVersion + "/user/cards/charge/setdef"
let kAPIChargeMoneyToBalance: String = kBaseURL + kAPIVersion + "/user/cards/charge"
let kAPIListTipHistory: String       = kBaseURL + kAPIVersion + "/user/balance/tip/history/list"

//MARK: Message Module
let kMessageStoryboardName                  = "KNMessage"

// MARK: Close current module
let kColoseCurrentModuleNotification:String = "kColoseCurrentModuleNotification"

//MARK: Passcode Utilities
let kPasscodeStoryboardName = "KNPasscode"
let kPasscodeStoryboardId   = "kEnterPasscodeStoryboardId"

// MARK - User defaults
let kItemNameKeychainPassowrd =   "TipperUserPassword"

// MARK: system version checking
func isIOS8OrHigher() -> Bool {
    var result: Bool
    switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        // iOS >= 8.0
        result = true
    case .OrderedAscending:
        // iOS < 8.0
        result = false
    }
    return result
}

//MARK: delay after seconds
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

