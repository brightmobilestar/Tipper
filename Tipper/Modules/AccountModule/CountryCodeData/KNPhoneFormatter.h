//
//  KNAppControlManager.h
//  EverAfter
//
//  Created by Jianying Shi on 6/26/14.
//

#import <Foundation/Foundation.h>

@interface KNPhoneFormatter : NSObject

@property (strong, readonly) NSMutableString *formattedPhoneNumber;
@property (strong, readonly) NSString *countryCode;

+ (KNPhoneFormatter *)phoneFormatter;

- (NSArray *)listOfCountrySupported;

- (BOOL)setCountryCode:(NSString *)countryCode;
- (BOOL)phoneNumberMustChangeInRange:(NSRange)range replacementString:(NSString *)string;
- (void)resetPhoneNumber;
- (void)setPhoneNumber:(NSString *)phoneNumber;
- (BOOL)isValid;

- (NSString *)unformatNumber:(NSString *)phoneNumber;

@end
