//
//  STPBankAccount.m
//  Stripe
//
//  Created by Charles Scalesse on 10/1/14.
//
//

#import "STPBankAccount.h"
#import "STPUtils.h"

@interface STPBankAccount ()

@property (nonatomic, readwrite) NSString *object;
@property (nonatomic, readwrite) NSString *bankAccountId;
@property (nonatomic, readwrite) NSString *last4;
@property (nonatomic, readwrite) NSString *bankName;
@property (nonatomic, readwrite) NSString *fingerprint;
@property (nonatomic, readwrite) NSString *currency;
@property (nonatomic, readwrite) BOOL validated;
@property (nonatomic, readwrite) BOOL disabled;

@end

@implementation STPBankAccount

#pragma mark - Constructors

- (instancetype)init {
    self = [super init];
    if (self) {
        self.object = @"bank_account";
    }
    return self;
}

- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary {
    self = [self init];
    if (self) {
        // sanitize NSNull
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [attributeDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (obj != [NSNull null]) {
                dictionary[key] = obj;
            }
        }];

        self.object = dictionary[@"object"];
        self.bankAccountId = dictionary[@"id"];
        self.last4 = dictionary[@"last4"];
        self.bankName = dictionary[@"bank_name"];
        self.country = dictionary[@"country"];
        self.fingerprint = dictionary[@"fingerprint"];
        self.currency = dictionary[@"currency"];
        self.validated = [dictionary[@"validated"] boolValue];
        self.disabled = [dictionary[@"disabled"] boolValue];
    }
    return self;
}

#pragma mark - Getters

- (NSString *)last4 {
    if (_last4) {
        return _last4;
    } else if (self.accountNumber && self.accountNumber.length >= 4) {
        return [self.accountNumber substringFromIndex:(self.accountNumber.length - 4)];
    } else {
        return nil;
    }
}

#pragma mark - STPFormEncodeProtocol

- (NSData *)formEncode {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSMutableArray *parts = [NSMutableArray array];

    if (_accountNumber)
        params[@"account_number"] = _accountNumber;
    if (_routingNumber)
        params[@"routing_number"] = _routingNumber;
    if (_country)
        params[@"country"] = _country;

    [params enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
        if (val != [NSNull null]) {
            [parts addObject:[NSString stringWithFormat:@"bank_account[%@]=%@", key, [STPUtils stringByURLEncoding:val]]];
        }
    }];

    return [[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Equality

- (BOOL)isEqual:(STPBankAccount *)bankAccount {
    return [self isEqualToBankAccount:bankAccount];
}

- (BOOL)isEqualToBankAccount:(STPBankAccount *)bankAccount {
    if (self == bankAccount) {
        return YES;
    }

    if (!bankAccount || ![bankAccount isKindOfClass:self.class]) {
        return NO;
    }

    return [self.accountNumber ?: @"" isEqualToString:bankAccount.accountNumber ?: @""] &&
           [self.routingNumber ?: @"" isEqualToString:bankAccount.routingNumber ?: @""] &&
           [self.country ?: @"" isEqualToString:bankAccount.country ?: @""] && [self.last4 ?: @"" isEqualToString:bankAccount.last4 ?: @""] &&
           [self.bankName ?: @"" isEqualToString:bankAccount.bankName ?: @""] && [self.currency ?: @"" isEqualToString:bankAccount.currency ?: @""];
}

@end
