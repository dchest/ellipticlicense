//
//  ProductStore.h
//  EllipticLicenseDeveloper
//
//  Created by Dmitry Chestnykh on 30.03.09.
//
//  Copyright (c) 2009 Dmitry Chestnykh, Coding Robots
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Cocoa/Cocoa.h>
#import "EllipticLicense.h"


@interface ProductStore : NSObject {
	NSString *curveName;
	NSInteger curveNameTag;
	NSInteger numberOfCharactersInDashGroup;
	NSString *publicKey;
	NSString *privateKey;
	NSArray *blockedLicenseKeys;
	EllipticLicense *ellipticLicense;
	BOOL isLocked;	
	NSString *obfuscatedPublicKeyCode;
	BOOL isChanged;
}
@property (copy) NSString *curveName;
@property (assign) NSInteger curveNameTag;
@property (assign) NSInteger numberOfCharactersInDashGroup;
@property (copy) NSString *publicKey;
@property (copy) NSString *privateKey;
@property (retain) NSArray *blockedLicenseKeys;
@property (copy, readonly) NSString *exampleLicenseKey;
@property (retain) EllipticLicense *ellipticLicense;
@property (assign) BOOL isLocked;
@property (copy) NSString *obfuscatedPublicKeyCode;

- (void)generateKeys;
- (NSString *)generateLicenseKeyForName:(NSString *)name;
- (NSString *)blockedLicenseKeysAsCode;

@end
