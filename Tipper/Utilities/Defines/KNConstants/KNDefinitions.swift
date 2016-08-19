//
//  File.swift
//  KNSWTemplate
//
//  Created by Peter van de Put on 24/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//

import Foundation
import UIKit

let appDelegate             = UIApplication.sharedApplication().delegate as KNAppDelegate
//MARK: App constant
//let appDelegate             = UIApplication.sharedApplication().delegate as KNAppDelegate
let MAIN_SCREEN:UIScreen    = UIScreen.mainScreen()
let ScreenWidth:CGFloat     = MAIN_SCREEN.bounds.size.width
let ScreenHeight:CGFloat    = MAIN_SCREEN.bounds.size.height
let StatusbarHeight:CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
let IsIphone4:Bool          = ScreenHeight == 480 ? true : false
let IsIphone6Plus:Bool      = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenHeight == 736.0
let iOS7                    = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
let iOS8OrHigher            = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)

// animation stuff
let kPushAndPopAnimationDuration: NSTimeInterval = 0.35

//Max number of return from friend search
let kSearchResultLimit      = "25"
//virtualBeacon
let kVirtualBeaconUUID  = "904C779B-F707-40F5-9953-7D719F5DD48F"


let kRegularFontName: String       = "HelveticaNeue"
let kLightFontName: String         = "HelveticaNeue-Light"
let kMediumFontName: String        = "HelveticaNeue-Medium"
let kBoldFontName: String          = "HelveticaNeue-Bold"
let kCondensedBoldFontName: String = "HelveticaNeue-CondensedBold"

let kBigFontSize: CGFloat     = 19.0
let kDefaultFontSize: CGFloat = 17.0
let kMediumFontSize: CGFloat  = 15.0
let kSmallFontSize: CGFloat   = 12.0
let kVerySmallFontSize: CGFloat   = 9.0
let kHugeFontSize : CGFloat = 27
let kExtraLargeFontSize : CGFloat = 36

let kTextColor:UIColor                = UIColor.whiteColor()
let kNavigationTitleTintColor:UIColor = UIColor.whiteColor()
let kNavigationTitleFont:UIFont       = UIFont(name: kRegularFontName, size: kBigFontSize)!
let kNavigationItemBarTitleFont       = UIFont(name: kRegularFontName, size: kMediumFontSize)!
let kCCViewMoneyTextLargeFont              = UIFont(name: kMediumFontName, size: kExtraLargeFontSize)!
let kCCViewMoneyTextSmallFont              = UIFont(name: kMediumFontName, size: kHugeFontSize)!


let kVerySmallFont              = UIFont(name: kRegularFontName, size: kVerySmallFontSize)!

let kChangeStoryboardTimer: NSTimeInterval = 0.5

let kMediaDirectory:String = "Media"

// MARK - Caremera picker
let kNewAvatarImageName:String = "new_Selected_Image"

// MARK - S3 Amazon
let kS3BucketAccessKey:String = "AKIAIMBNZBMDEKDBBPNA"
let kS3BucketSecretKey:String = "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"
let kS3BucketName:String      = "tipper-avatar"
let kS3BaseURL:String         = "https://s3.amazonaws.com/\(kS3BucketName)/"

// MARK - Flurry
let kFlurryApiKey:String        = "8YDFSKC2SM5DG74QBMBT"

// MARK - Google Anamytics
let kGoogleAnalyticsKey:String  = "UA-53851491-5"

//// MARK - api ulr
let kAPITestRoute:String        = ""

//MARK: Main
let kMainStoryboardName: String = "Main"

// Withdraw module
let kWithdrawModuleStoryboardName: String = "WithdrawStoryboard"
let kWithdrawFirstViewControllerID: String = "KNWithdrawFirstViewController"
let kWithdrawChooseCardViewControllerID: String = "KNWithdrawChooseCardViewController"
let kWithdrawConfirmViewController: String = "KNWithdrawConfirmViewController"
let kWithdrawNavigationController: String = "WithdrawNavigationController"

//MARK: Splash module
let kSecondToDisplaySplash:NSTimeInterval                     = 0.5
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
let kLoginStoryboardId: String   = "KNLoginViewController"

//MARK: Profile Module
let kProfileStoryboardName: String   = "KNProfile"
let kEditProfileStoryboardId: String = "kEditProfileStoryboardId"
let kFavoriteButtonBackgroundHighlighted: UIColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
let kFavoriteButtonBackgroundNormal: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
let kTipButtonBackgroundNormal: UIColor = UIColor(red: 36.0/255, green: 166.0/255, blue: 240.0/255, alpha: 1)
let kTipButtonForegroundHighlighted: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
let kTipButtonBackgroundHighlighted: UIColor = UIColor(red: 26.0/255, green: 128.0/255, blue: 186.0/255, alpha: 1)

//MARK: Account Module
let kAccountStoryboardName: String     = "KNAccount"
let kAccountCreateStoryboardId: String = "kAccountCreateStoryboardId"

//MARK: Tutorial
let kUseTutorial:Bool              = false
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
let kDeleteCardViewControllerId: String   = "KNDeleteCCViewController"
let kWithdrawBalanceViewControllerId: String = "KNWithdrawViewController"

//MAKR - Edit Avatar
let kEditImageStoryboardName:String         = "KNEditImage"
let kEditImageViewControllerId: String      = "KNEditImageViewController"
let kEditImageCropButtonBorderWidth:CGFloat = 2.0


//MARK: API communication
//let  kBaseURL:String = "http://10.1.70.150:3100"
let  kBaseURL:String = "http://tipper-dev.knodeit.com"

//MARK production is now running with SSL 
//let  kBaseURL:String = "https://tipper.knodeit.com"
let  kAPIStatusOk    = "ok"
let  kAPIStatusError = "error"
let kTempAccessToken = "f78464c7-2229-49d3-82f0-ac612c662503"


//MARK: Withdraw
let kShowWithdrawConfirmation   = "kShowWithdrawConfirmation"


//MARK: Routes
let kAPIVersion: String                     = "/api/v1"
let kAPICheckEmailExist: String             = kBaseURL + kAPIVersion + "/user/exist"
let kAPILogin: String                       = kBaseURL + kAPIVersion + "/user/login"
let kAPILogout: String                      = kBaseURL + kAPIVersion + "/user/logoff"
let kAPIRegister: String                    = kBaseURL + kAPIVersion + "/user/registration/add"
let kAPIDeleteRegister: String              = kBaseURL + kAPIVersion + "/user/registration/delete"
let kAPISendCodeToPhone: String             = kBaseURL + kAPIVersion + "/user/mobile/verification/request"

let kAPIRequestVerification: String         = kBaseURL + kAPIVersion + "/user/mobile/verification/request"
//NEW
let kAPISendVerificationRequest: String         = kBaseURL + kAPIVersion + "/user/mobile/verification/send"


let kAPIForgotPasswordWithEmail: String     = kBaseURL + kAPIVersion + "/user/password/email/forgot"
let kAPIResetPasswordWithEmail: String      = kBaseURL + kAPIVersion + "/user/password/email/reset"

let kAPIForgotPasswordWithMobile: String    = kBaseURL + kAPIVersion + "/user/password/mobile/forgot"
let kAPIResetPasswordWithMobile: String     = kBaseURL + kAPIVersion + "/user/password/mobile/reset"


let kAPIResendCodeToPhone: String           = kBaseURL + kAPIVersion + "/user/mobile/verification/resend"
let kAPIPhoneVerification: String           = kBaseURL + kAPIVersion + "/user/mobile/verification"
let kAPIGetProfile: String                  = kBaseURL + kAPIVersion + "/user/profile/info"
let kAPIUpdateProfile: String               = kBaseURL + kAPIVersion + "/user/profile/update"
let kAPISetUpPinCode: String                = kBaseURL + kAPIVersion + "/user/profile/pincode"
let kAPICheckPinCode: String                = kBaseURL + kAPIVersion + "/user/profile/pincode/check"
let kAPIGetCurrentBlance: String            = kBaseURL + kAPIVersion + "/user/balance"
let kAPIBalanceTip: String                  = kBaseURL + kAPIVersion + "/user/balance/tip"

let kAPIUpdateUserLocation: String          = kBaseURL + kAPIVersion + "/user/location"


let kAPISyncAddressBook: String             = kBaseURL + kAPIVersion + "/user/addressbook/sync"
let kAPIGetTaskId: String                   = kBaseURL + kAPIVersion + "/user/friends/find"
let kAPITaskStatus: String                  = kBaseURL + kAPIVersion + "/user/friends/find/status"
let kAPIGetListOfFriends: String            = kBaseURL + kAPIVersion + "/user/friends/list"
let kAPISearchFriends: String               = kBaseURL + kAPIVersion + "/user/friends/search"
let kAPIAddFriend: String                   = kBaseURL + kAPIVersion + "/user/friends/add"
let kAPIFriendsNearby: String               = kBaseURL + kAPIVersion + "/user/friends/nearby"

let kAPIFavorite: String                    = kBaseURL + kAPIVersion + "/user/friends/favorite"


let kAPIListRegisteredCards: String         = kBaseURL + kAPIVersion + "/user/cards/list"
//let kAPIAddCard: String                     = kBaseURL + kAPIVersion + "/user/cards/credit/add"
let kAPIAddCard: String                     = kBaseURL + kAPIVersion + "/user/card/add"
let kAPIDeleteCard: String                  = kBaseURL + kAPIVersion + "/user/cards/credit/delete"
let kAPISetDefaultCard: String              = kBaseURL + kAPIVersion + "/user/cards/credit/setdef"
let kAPIChargeMoneyToBalance: String        = kBaseURL + kAPIVersion + "/user/cards/credit"
let kAPIListTipHistory: String              = kBaseURL + kAPIVersion + "/user/balance/tip/history/list"
let kAPISendDeviceToken:String              = kBaseURL + kAPIVersion + "/user/device/token"
let kAPIReceivedTipHistory:String           = kBaseURL + kAPIVersion + "/user/balance/tip/history/received"
//let kAPIWithdrawBalance:String              = kBaseURL + kAPIVersion + "/user/balance/transfer"
let kAPIWithdrawBalance:String              = kBaseURL + kAPIVersion + "/user/balance/payout"
let kAPIDebitAddCard: String                = kBaseURL + kAPIVersion + "/user/cards/debit/add"
let kAPIListDebitRegisteredCards: String    = kBaseURL + kAPIVersion + "/user/cards/debit/list"
let kAPIDeleteDebitCard: String             = kBaseURL + kAPIVersion + "/user/cards/debit/delete"
let kAPISetDefaultDebitCard: String         = kBaseURL + kAPIVersion + "/user/cards/debit/setdef"

//Added 1.14.2015
let kAPIDeleteTipperCard: String            = kBaseURL + kAPIVersion + "/user/cards/delete"
let kAPIGetCMSPageBySlug: String            = kBaseURL + kAPIVersion + "/page/"
let kAPIGetCMSPages: String                 = kBaseURL + kAPIVersion + "/pages"
//Added 1.16.2015
let kAPIUpdateNotificationSettings: String  = kBaseURL + kAPIVersion + "/user/profile/notification/push"
//Added 1.27.2015
let kAPITipNonExistingUser: String          = kBaseURL + kAPIVersion + "/user/balance/tip/user/notexists"
//user state
let kAPIUserAcceptedAddressBookAccess: String  = kBaseURL + kAPIVersion + "/user/addressbook/allowed"
let kAPIUserAcceptedLocationManager: String    = kBaseURL + kAPIVersion + "user/location/allowed"
let kAPIsetUserLangauge: String             = kBaseURL + kAPIVersion + "/user/language"

let kAPIDiscoverFriendProfile: String             = kBaseURL + kAPIVersion + "/user/friends/discover"


//MARK: Message Module
let kMessageStoryboardName                  = "KNMessage"

// MARK: Close current module
let kColoseCurrentModuleNotification:String = "kColoseCurrentModuleNotification"

//MARK: Passcode Utilities
let kPasscodeStoryboardName = "KNPasscode"
let kPasscodeStoryboardId   = "kEnterPasscodeStoryboardId"

//MARK: Main Module (Tipper Module)
let kTipperModuleStoryboardName = "KNTipper"
let kProfileViewControllerID = "KNProfileViewController"


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
//MARK AB sync
let kAddressBookSynced:String              = "kAddressBookSynced"

//MARK: colors

let kColorDisableButton: UIColor = UIColor.lightGrayColor()

//MARK: Image names
let kUserPlaceHolderImageName           = "avatarPleaceholderSearch"
