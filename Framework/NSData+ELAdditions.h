//
//  NSData+ELAdditions.h
//  EllipticLicense
//
//  Created by Dmitry Chestnykh on 28.03.09.
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
//
//
//  Base32 encoding/decoding methods taken from public domain code at
//  http://www.cocoadev.com/index.pl?NSDataCategory


#import <Cocoa/Cocoa.h>


@interface NSData (ELAdditions)

+ (NSData *)el_dataWithBase32String:(NSString *)base32;
- (NSString *)el_base32String;
- (NSData *)el_sha1Digest;
- (NSString *)el_sha1DigestString;
+ (NSData *)el_dataWithHexString:(NSString *)hexString;
- (NSString *)el_hexString;
+ (NSData *)el_dataWithString:(NSString *)string;
+ (NSData *)el_dataWithStringNoNull:(NSString *)string;

@end
