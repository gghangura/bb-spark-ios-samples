/* Copyright (c) 2017 BlackBerry.  All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.

 * This sample code was created by BlackBerry using SDKs from Apple Inc.
 * and may contain code licensed for use only with Apple products.
 * Please review your Apple SDK Agreement for additional details.
 */ 


#import <Foundation/Foundation.h>
#import "Contact.h"

@protocol ContactsListener <NSObject>

- (void)contactsChanged:(NSArray *)contacts;

@end


@interface ContactManager : NSObject

+ (ContactManager *)sharedInstance;

- (void)registerLocalUser:(NSString *)uid
                    regId:(NSString *)regId
                     name:(NSString *)name
                      pin:(NSString *)pin
                    email:(NSString *)email
                avatarUrl:(NSString *)avatarUrl;

- (void)addContactsListener:(id<ContactsListener>)listener;

- (void)removeContactsListener:(id<ContactsListener>)listener;

- (Contact *)contactForRegId:(NSNumber *)regId;


@end