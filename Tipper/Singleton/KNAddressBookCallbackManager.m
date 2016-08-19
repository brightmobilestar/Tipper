//
//  KNAddressBookCallbackManager.m
//  Tipper
//
//  Created by Peter van de Put on 24/01/2015.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

#import "KNAddressBookCallbackManager.h"
#import <AddressBook/AddressBook.h>

@interface KNAddressBookCallbackManager(){
    
    ABAddressBookRef addressBook;

}
@end


@implementation KNAddressBookCallbackManager


+ (KNAddressBookCallbackManager*)sharedInstance {
    static id sharedInstance = nil;
    
    if ( !sharedInstance ){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
            
        });
    }
    
    
    return (KNAddressBookCallbackManager*)sharedInstance;
}


- (id) init{
    self = [super init];
    if ( self != nil){
        CFErrorRef *error = nil;
        
        addressBook = ABAddressBookCreateWithOptions(NULL, error);
         ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge_retained  void *)self);
      }
    return self;
}




void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context){
 
    //Something has changed perform your action
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KNAddressBookChanged" object:nil];
    
}


@end
