//
//  EllipticLicense.m
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

#import "EllipticLicense.h"
#import "NSData+ELAdditions.h"
#include <openssl/err.h>
#include <openssl/evp.h>

@interface EllipticLicense (Private)
- (NSString *)stringSeparatedWithDashes:(NSString *)string;
- (NSString *)cleanKeyFromLicenseKey:(NSString *)licenseKey;
@end


@implementation EllipticLicense

@synthesize blockedLicenseKeyHashes;

+ (void)initialization;
{
	ERR_load_crypto_strings();
}

- (id)init;
{
	if (![super init])
		return nil;
	[self setCurveName:ELCurveNameSecp112r1]; // Set default curve
	return self;
}

- (id)initWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey curveName:(NSString *)curve;
{
	if (![self init])
		return nil;
	if (curveName)
		[self setCurveName:curve];
	if (![self setPublicKey:publicKey privateKey:privateKey])
		return nil;
	return self;
}

- (id)initWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;
{
	return [self initWithPublicKey:publicKey privateKey:privateKey curveName:nil];
}

- (id)initWithPublicKey:(NSString *)publicKey curveName:(NSString *)curve;
{
	return [self initWithPublicKey:publicKey privateKey:nil curveName:curve];
}

- (id)initWithPublicKey:(NSString *)publicKey;
{
	return [self initWithPublicKey:publicKey curveName:nil];
}


- (void)setCurveName:(NSString *)name;
{	
	if ([name isEqualToString:ELCurveNameSecp160r1]) {
		curveName = NID_secp160r1;
		digestLength = 20; // Full SHA-1 length
		base32signatureLength = 64;
		numberOfDashGroupCharacters = 8;
	}
	else if ([name isEqualToString:ELCurveNameSecp128r1]) {
		curveName = NID_secp128r1;
		digestLength = 16; // SHA-1 is 20 bytes, but since we use 16-byte curve, we must crop it
		base32signatureLength = 52;
		numberOfDashGroupCharacters = 4;
	}
	else { // default is ELCurveNameSecp112r1
		curveName = NID_secp112r1;
		digestLength = 14; // SHA-1 is 20 bytes, but since we use 14-byte curve, we must crop it
		base32signatureLength = 45;
		numberOfDashGroupCharacters = 5;
	}
}

- (void)setNumberOfDashGroupCharacters:(unsigned int)number;
{
	numberOfDashGroupCharacters = number;
}

- (unsigned int)numberOfDashGroupCharacters;
{
	return numberOfDashGroupCharacters;
}

- (BOOL)setPublicKey:(NSString *)publicKey;
{
	return [self setPublicKey:publicKey privateKey:nil];
}

- (BOOL)setPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;
{
	if (ecKey)
		EC_KEY_free(ecKey); 
	ecKey = EC_KEY_new_by_curve_name(curveName);
	if (ecKey == NULL)
		return NO;

	NSData *publicKeyData = [NSData el_dataWithHexString:publicKey];
	const unsigned char *pubBytes = [publicKeyData bytes];
	ecKey = o2i_ECPublicKey(&ecKey, &pubBytes, [publicKeyData length]);
	if (ecKey == NULL)
		return NO;

	if (privateKey) {
		NSData *privateKeyData = [NSData el_dataWithHexString:privateKey];
		const unsigned char *privBytes = [privateKeyData bytes];
		ecKey = d2i_ECPrivateKey(&ecKey, &privBytes, [privateKeyData length]);
		if (ecKey == NULL)
			return NO;
	}
	return (EC_KEY_check_key(ecKey));
}


- (BOOL)generateKeys;
{
	if (ecKey)
		EC_KEY_free(ecKey);
	ecKey = EC_KEY_new_by_curve_name(curveName);
	if (!ecKey)
		return NO;
	return EC_KEY_generate_key(ecKey);
}

- (NSString *)publicKey;
{
	unsigned char *bytes = NULL;
	int length = i2o_ECPublicKey(ecKey, &bytes);
	return [[NSData dataWithBytesNoCopy:bytes length:length] el_hexString];
}

- (NSString *)privateKey;
{
	unsigned char *bytes = NULL;
	int length = i2d_ECPrivateKey(ecKey, &bytes);
	return [[NSData dataWithBytesNoCopy:bytes length:length] el_hexString];
}

- (NSString *)licenseKeyForName:(NSString *)name;
{
	NSData *digest = [[NSData el_dataWithStringNoNull:name] el_sha1Digest];
	if (!digest)
		return nil;
	ECDSA_SIG *signature = ECDSA_do_sign([digest bytes], digestLength, ecKey);
	if (signature == NULL)
		return nil;

	size_t rlen = BN_num_bytes(signature->r);
	size_t slen = BN_num_bytes(signature->s);
	unsigned char *signatureBytes = OPENSSL_malloc(rlen+slen);
	BN_bn2bin(signature->r, signatureBytes);
	BN_bn2bin(signature->s, signatureBytes+rlen); // join two values into signatureBytes
	NSMutableData *signatureData = [NSMutableData dataWithBytesNoCopy:signatureBytes length:rlen+slen];

	return [self stringSeparatedWithDashes:[signatureData el_base32String]];
}

- (BOOL)verifyLicenseKey:(NSString *)licenseKey forName:(NSString *)name;
{
	if (!name || [name length] == 0)
		return NO;

	NSString *cleanKey = [self cleanKeyFromLicenseKey:licenseKey];
	
	// Check length of signature before decoding
	if ([cleanKey length] != base32signatureLength)
		return NO;
	
	// Check if license key is blocked. Note that we use key without dashes
	if ([self isBlockedLicenseKey:cleanKey])
		return NO;
	
	ECDSA_SIG *signature = ECDSA_SIG_new();
	if (!signature)
		return NO;
	
	NSData *signatureData = [NSData el_dataWithBase32String:cleanKey];
	size_t partLen = [signatureData length]/2;
	signature->r = BN_bin2bn([signatureData bytes], partLen, signature->r);
	signature->s = BN_bin2bn([signatureData bytes] + partLen, partLen, signature->s);
	if (!signature->r || !signature->s) {
		ECDSA_SIG_free(signature);
		return NO;		
	}
	NSData *digest = [[NSData el_dataWithStringNoNull:name] el_sha1Digest];
	if ([digest length] < digestLength) {
		ECDSA_SIG_free(signature);
		return NO;
	}
	BOOL result = ECDSA_do_verify([digest bytes], digestLength, signature, ecKey);

	ECDSA_SIG_free(signature);
	return result;
}

- (NSString *)hashStringOfLicenseKey:(NSString *)licenseKey;
{
	NSString *cleanLicense = [self cleanKeyFromLicenseKey:licenseKey];
	return [[NSData el_dataWithStringNoNull:cleanLicense] el_sha1DigestString];
}

- (BOOL)isBlockedLicenseKey:(NSString *)licenseKey;
{
	if (!blockedLicenseKeyHashes)
		return NO;
	return [blockedLicenseKeyHashes containsObject:[self hashStringOfLicenseKey:licenseKey]];
}

- (void)logKeys;
{
	NSLog(@"Public Key:\n%@", [self publicKey]);
	NSLog(@"Private Key:\n%@", [self privateKey]);
}

- (void)dealloc;
{
	ERR_free_strings();
	if (ecKey)
		EC_KEY_free(ecKey);
	[super dealloc];
}

- (void)finalize;
{
	ERR_free_strings();
	if (ecKey)
		EC_KEY_free(ecKey);
	[super finalize];
}

@end

@implementation EllipticLicense (Private)

- (NSString *)stringSeparatedWithDashes:(NSString *)string;
{
	if (numberOfDashGroupCharacters == 0)
		return [[string copy] autorelease];
	NSMutableString *result = [string mutableCopy];
	int i = numberOfDashGroupCharacters;
	while (i < [result length]) {
		[result insertString:@"-" atIndex:i];
		i += numberOfDashGroupCharacters + 1;
	}	
	return [result autorelease];
}


- (NSString *)cleanKeyFromLicenseKey:(NSString *)licenseKey;
{
	NSMutableString *cleanKey = [licenseKey mutableCopy];
	[cleanKey replaceOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, [cleanKey length])];
	// Fix wrong characters that are not in base32, but can be mistakened // Workaround, better fix base32 decoding to include this
	[cleanKey replaceOccurrencesOfString:@"0" withString:@"O" options:0 range:NSMakeRange(0, [cleanKey length])];
	[cleanKey replaceOccurrencesOfString:@"1" withString:@"I" options:0 range:NSMakeRange(0, [cleanKey length])];
	[cleanKey replaceOccurrencesOfString:@"8" withString:@"B" options:0 range:NSMakeRange(0, [cleanKey length])];
	return [cleanKey autorelease];
}

@end

