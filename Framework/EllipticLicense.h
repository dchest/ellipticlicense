//
//  EllipticLicense.h
//  EllipticLicense
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
#include <openssl/sha.h>
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>
#include <openssl/ossl_typ.h>

NSString *ELCurveNameSecp112r1 = @"secp112r1";
NSString *ELCurveNameSecp128r1 = @"secp128r1";
NSString *ELCurveNameSecp160r1 = @"secp160r1";

@interface EllipticLicense : NSObject {
	EC_KEY *ecKey;

	NSArray *blockedLicenseKeyHashes; // List of SHA-1 hashes of blocked license keys (without dashes). Use hashStringOfLicenseKey to get proper hash. Use setBlockedLicenseKeyHashes to set it.

	unsigned int numberOfDashGroupCharacters; // number of characters in groups in final license key (xxxxx-xxxxx-...)
	
	unsigned int curveName; // (internal) name of curve. Use setCurveName to set it with ELCurveName* strings. Default is ELCurveNameSecp112r1 (SECG/WTLS curve over a 112 bit prime field)
	
	unsigned int digestLength; // (internal) Length of SHA-1 digest used for signature. Can be less than the real length of SHA-1 for less than 160-bit curves: in this case we'll cut SHA-1 to digestLength.  Changes with setCurveName.

	unsigned int base32signatureLength; // (internal) length of signature without dashes. Changes with setCurveName.
}

- (id)initWithPublicKey:(NSString *)publicKey;
- (id)initWithPublicKey:(NSString *)publicKey curveName:(NSString *)curve;
- (id)initWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;
- (id)initWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey curveName:(NSString *)curve;
- (void)setCurveName:(NSString *)name;
- (void)setNumberOfDashGroupCharacters:(unsigned int)number;
- (unsigned int)numberOfDashGroupCharacters;

- (BOOL)setPublicKey:(NSString *)publicKey;
- (BOOL)setPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;
- (NSString *)privateKey;
- (NSString *)publicKey;

@property(retain) NSArray *blockedLicenseKeyHashes;
- (BOOL)isBlockedLicenseKey:(NSString *)licenseKey;

- (BOOL)generateKeys;
- (void)logKeys;

- (NSString *)hashStringOfLicenseKey:(NSString *)licenseKey;

- (NSString *)licenseKeyForName:(NSString *)name;
- (BOOL)verifyLicenseKey:(NSString *)signature forName:(NSString *)name;

@end
