//
//  ProductStore.m
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

#import "ProductStore.h"
#import "EllipticLicense.h"

NSString *exampleKeyString = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

@interface ProductStore (Private)
- (NSString *)generateObfuscatedPublicKeyCode;
@end


@implementation ProductStore

@synthesize curveName;
@synthesize numberOfCharactersInDashGroup;
@synthesize publicKey;
@synthesize privateKey;
@synthesize blockedLicenseKeys;
@synthesize ellipticLicense;
@synthesize isLocked;
@synthesize obfuscatedPublicKeyCode;

+ (void)initialize;
{
	srandom(time(NULL));
}

- (id)init;
{
	if (![super init])
		return nil;
	ellipticLicense = [[EllipticLicense alloc] init];
	[self setCurveName:ELCurveNameSecp112r1];
	[self setBlockedLicenseKeys:[NSMutableArray array]];
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder;
{
	if (![super init])
		return nil;
	ellipticLicense = [[EllipticLicense alloc] init];
	[self setCurveName:[decoder decodeObjectForKey:@"curveName"]];
	[self setNumberOfCharactersInDashGroup:[decoder decodeIntegerForKey:@"numberOfCharactersInDashGroup"]];
	[self setPrivateKey:[decoder decodeObjectForKey:@"privateKey"]];
	[self setPublicKey:[decoder decodeObjectForKey:@"publicKey"]];
	[self setBlockedLicenseKeys:[decoder decodeObjectForKey:@"blockedLicenseKeys"]];
	[self setObfuscatedPublicKeyCode:[decoder decodeObjectForKey:@"obfuscatedPublicKeyCode"]];
	[self setIsLocked:YES]; // do not decode this, just put yes

	[ellipticLicense setPublicKey:[self publicKey] privateKey:[self privateKey]];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
	[encoder encodeObject:curveName forKey:@"curveName"];
	[encoder encodeInteger:numberOfCharactersInDashGroup forKey:@"numberOfCharactersInDashGroup"];
	[encoder encodeObject:publicKey forKey:@"publicKey"];
	[encoder encodeObject:privateKey forKey:@"privateKey"];
	[encoder encodeObject:blockedLicenseKeys forKey:@"blockedLicenseKeys"];
	[encoder encodeObject:obfuscatedPublicKeyCode forKey:@"obfuscatedPublicKeyCode"];
	[encoder encodeBool:isLocked forKey:@"isLocked"];
}

- (void)dealloc;
{
	[curveName release];
	[publicKey release];
	[privateKey release];
	[blockedLicenseKeys release];
	[ellipticLicense release];
	[super dealloc];
}

- (NSInteger)curveNameTag;
{
	if ([[self curveName] isEqualToString:ELCurveNameSecp112r1])
		return 0;
	else if ([[self curveName] isEqualToString:ELCurveNameSecp128r1])
		return 1;
	else if ([[self curveName] isEqualToString:ELCurveNameSecp160r1])
		return 2;
	else
		return 0;
}

- (void)setCurveNameTag:(NSInteger)tag;
{
	[self willChangeValueForKey:@"curveNameTag"];
	switch (tag) {
		case 0 : [self setCurveName:ELCurveNameSecp112r1]; break;
		case 1 : [self setCurveName:ELCurveNameSecp128r1]; break;
		case 2 : [self setCurveName:ELCurveNameSecp160r1]; break;
	};
	[self didChangeValueForKey:@"curveNameTag"];
}

- (void)setCurveName:(NSString *)name;
{
	[self willChangeValueForKey:@"curveName"];
	[self willChangeValueForKey:@"exampleLicenseKey"];
	if (curveName == name)
		return;
	[curveName release];
	curveName = [name copy];
	[ellipticLicense setCurveName:curveName];
	[self setNumberOfCharactersInDashGroup:[ellipticLicense numberOfDashGroupCharacters]];
	[self didChangeValueForKey:@"exampleLicenseKey"];
	[self didChangeValueForKey:@"curveName"];
	[self generateKeys];
}

- (void)setNumberOfCharactersInDashGroup:(NSInteger)number;
{
	[self willChangeValueForKey:@"numberOfCharactersInDashGroup"];
	[self willChangeValueForKey:@"exampleLicenseKey"];
	numberOfCharactersInDashGroup = number;
	[ellipticLicense setNumberOfDashGroupCharacters:number];
	[self didChangeValueForKey:@"exampleLicenseKey"];
	[self didChangeValueForKey:@"numberOfCharactersInDashGroup"];
}

- (NSString *)stringSeparatedWithDashes:(NSString *)string numberOfCharactersInGroup:(NSInteger)number;
{
	if (number == 0)
		return [[string copy] autorelease];
	NSMutableString *result = [string mutableCopy];
	int i = number;
	while (i < [result length]) {
		[result insertString:@"-" atIndex:i];
		i += number + 1;
	}	
	return [result autorelease];
}

- (NSString *)exampleLicenseKey;
{
	NSUInteger keyLength;
	switch ([self curveNameTag]) {
		case 0: keyLength = 45; break;
		case 1: keyLength = 52; break;
		case 2: keyLength = 64;	break;
	}

	NSString *exampleKey = [exampleKeyString substringToIndex:keyLength];
	return [self stringSeparatedWithDashes:exampleKey numberOfCharactersInGroup:[self numberOfCharactersInDashGroup]];
}

- (void)setBlockedLicenseKeys:(NSArray *)keys;
{
	[self willChangeValueForKey:@"blockedLicenseKeys"];
	if (blockedLicenseKeys == keys)
		return;
	NSMutableArray *hashes = [NSMutableArray array];
	for (id obj in keys) {
		[hashes addObject:[obj objectForKey:@"hash"]];
	}
	if ([hashes count] > 0)
		[ellipticLicense setBlockedLicenseKeyHashes:hashes];
	
	[blockedLicenseKeys release];
	blockedLicenseKeys = [keys retain];
	[self didChangeValueForKey:@"blockedLicenseKeys"];
}

#pragma mark -

- (void)generateKeys;
{
	if (![ellipticLicense generateKeys])
		return; //show error
	[self setPublicKey:[ellipticLicense publicKey]];
	[self setPrivateKey:[ellipticLicense privateKey]];
	[self setObfuscatedPublicKeyCode:[self generateObfuscatedPublicKeyCode]];
	[self setBlockedLicenseKeys:[NSMutableArray array]];
}

- (NSString *)generateLicenseKeyForName:(NSString *)name;
{
	if (![self isLocked])
		[self setIsLocked:YES];
	return [ellipticLicense licenseKeyForName:name];
}

#pragma mark -

- (NSString *)generateObfuscatedPublicKeyCode;
{
	NSMutableString *code = [NSMutableString string];
	[code appendString:@"\n"
		 "\t//*** Begin Public Key ***\n"
	 "\tNSMutableString *key = [NSMutableString string];\n"];

	NSString *key = [self publicKey];
	NSInteger keyLength = [key length];
	NSRange range = NSMakeRange(0, 0);
	range.length += (random() % (keyLength/4-2)) + 1;
	do {
		[code appendFormat:@"\t[key appendString:\"%@\"];\n", [key substringWithRange:range]];
		range.location += range.length;
		range.length = (random() % (keyLength/4-2)) + 1;
	} while (range.location + range.length < keyLength);
	
	range.length = keyLength - range.location;
	[code appendFormat:@"\t[key appendString:\"%@\"];\n", [key substringWithRange:range]];
	
	[code appendString:@"\t// *** End Public Key ***\n"];
	return code;
}

- (NSString *)blockedLicenseKeysAsCode;
{
	if ([[self blockedLicenseKeys] count] == 0)
		return @"\t// No blocked keys";
	NSMutableString *code = [NSMutableString string];
	[code appendString:@"\n"
	 "\t//*** Begin Blocked Keys ***\n"
	 "\tNSMutableArray *blockedKeys = [NSMutableArray array];\n"];
	for (id obj in [self blockedLicenseKeys]) {
		[code appendFormat:@"\t// Key: %@\n", [obj objectForKey:@"key"]];
		[code appendFormat:@"\t[blockedKeys addObject:@\"%@\"];\n", [obj objectForKey:@"hash"]];
	}
	[code appendString:@"\t// *** End Blocked Keys ***\n"];
	return code;
}

@end
