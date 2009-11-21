//
//  MyDocument.h
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
#import "ProductStore.h"

@interface MyDocument : NSDocument
{
	ProductStore *productStore;
	
	IBOutlet id licenseNameTextField;
	IBOutlet id licenseKeyTextField;
	IBOutlet id formattedLicenseTextView;
	IBOutlet id codeTextView;
	IBOutlet id codePopUpButton;
	
	IBOutlet id blockKeyWindow;
	IBOutlet id blockKeyTextField;
	IBOutlet id blockedKeysController;
}

@property (retain) ProductStore *productStore;
- (IBAction)generateKeys:(id)sender;
- (IBAction)generateLicenseKey:(id)sender;
- (IBAction)verifyLicenseKey:(id)sender;
- (IBAction)showCode:(id)sender;

- (IBAction)addBlockedKey:(id)sender;
- (IBAction)closeBlockKeySheet:(id)sender;
- (IBAction)doAddBlockedKey:(id)sender;
@end
