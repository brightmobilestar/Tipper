//
//  KNAppControlManager.h
//  EverAfter
//
//  Created by Jianying Shi on 6/26/14.
//
#import "KNPhoneFormatter.h"

@interface KNPhoneFormatter ()

- (void)formatPhoneNumber;

@end

@implementation KNPhoneFormatter
{
    NSArray *_countries;
    NSString *_format;
    int _numberOfDigits;
}

static KNPhoneFormatter *_sharedInstance = nil;

+ (KNPhoneFormatter *)phoneFormatter
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[KNPhoneFormatter alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FormatsCountriesPhone" ofType:@"plist"];
        _countries = [[NSArray alloc] initWithContentsOfFile:path];
                
        _formattedPhoneNumber = [[NSMutableString alloc] init];
        [self setCountryCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
    }
    
    return self;
}

- (void)resetPhoneNumber {
    [_formattedPhoneNumber setString:@""];
}

- (NSArray *)listOfCountrySupported
{
    return _countries;
}

- (BOOL)setCountryCode:(NSString *)countryCode
{
    countryCode = [countryCode uppercaseString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(code == %@)", countryCode ];
    NSArray *result = [_countries filteredArrayUsingPredicate:predicate];

    if ([result count] == 1) {
        _countryCode = countryCode;
        _format = [[result lastObject] objectForKey:@"format"];
        _numberOfDigits = (int)[[_format componentsSeparatedByString:@"X"] count] - 1;

        [self formatPhoneNumber];
        
        return YES;
    }
    else{
        _countryCode = countryCode;
        _format = @"X XX XX XX XX";
        _numberOfDigits = (int)[[_format componentsSeparatedByString:@"X"] count] - 1;
        
        [self formatPhoneNumber];
        return YES;
    }
    
    return NO;
}

- (BOOL)phoneNumberMustChangeInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL mustChange = YES;
    
    if (_formattedPhoneNumber.length >= _format.length)
        mustChange = NO;
    
    if (![[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:string]])
        mustChange = NO;
    
    if (range.length == 1)
        mustChange = YES;
    
    if (mustChange == YES) {
        [_formattedPhoneNumber replaceCharactersInRange:range withString:string];
        [self formatPhoneNumber];
    }
    
    return mustChange;
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    if (phoneNumber == nil) {
        _formattedPhoneNumber = [NSMutableString new];
    } else {
        _formattedPhoneNumber = [phoneNumber mutableCopy];
    }
    
    [self formatPhoneNumber];
}

- (BOOL)isValid
{
    [self formatPhoneNumber];
    
    if (_formattedPhoneNumber.length == _format.length) {
        return YES;
    }
    
    return NO;
}

- (void)formatPhoneNumber
{
    NSMutableString *formattedNumber = [[NSMutableString alloc] init];
    NSString *number = [self unformatNumber:_formattedPhoneNumber];
    
    int k = 0;
    
    for (int i = 0; i < [_format length]; i++) {
        
        if (k >= [number length])
            break;
            
        NSString *character = [_format substringWithRange:NSMakeRange(i, 1)];
        
        if ([character isEqualToString:@"X"]) {
            [formattedNumber appendString:[number substringWithRange:NSMakeRange(k, 1)]];
            k++;
        } else {
            [formattedNumber appendString:character];
        }
    }
    
    _formattedPhoneNumber = formattedNumber;
}

- (NSString *)unformatNumber:(NSString *)phoneNumber
{
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    return phoneNumber;
}

@end
