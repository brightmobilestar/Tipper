//
//  AddressBookExternalChangeCallback.m
//  Tipper
//
//  Created by Peter van de Put on 24/01/2015.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

#import "AddressBookExternalChangeCallback.h"

@implementation AddressBookExternalChangeCallback


void addressBookExternalChangeCallback(ABAddressBookRef addressBookRef, CFDictionaryRef info, void *context){
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressBookDidChangeExternallyNotification" object:nil];
    });
}

void registerExternalChangeCallbackForAddressBook(ABAddressBookRef addressBookRef){
    ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookExternalChangeCallback, nil);
}
@end
