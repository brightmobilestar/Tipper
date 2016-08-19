//
//  AddressBookExternalChangeCallback.h
//  Tipper
//
//  Created by Peter van de Put on 24/01/2015.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
@interface AddressBookExternalChangeCallback : NSObject
void registerExternalChangeCallbackForAddressBook(ABAddressBookRef addressBookRef);
@end
