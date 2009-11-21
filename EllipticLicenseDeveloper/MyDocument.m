//
//  MyDocument.m
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

#import "MyDocument.h"


@implementation MyDocument
@synthesize productStore;

- (id)init;
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		[self setProductStore:[[[ProductStore alloc] init] autorelease]];
		[self updateChangeCount:NSChangeDone];
    }
    return self;
}

- (void)setProductStore:(ProductStore *)newStore;
{
	if (productStore == newStore)
		return;
	[productStore removeObserver:self forKeyPath:@"blockedLicenseKeys"];
	[productStore removeObserver:self forKeyPath:@"publicKey"];
	[productStore removeObserver:self forKeyPath:@"numberOfCharactersInDashGroup"];
	[productStore release];
	productStore = [newStore retain];
	[productStore addObserver:self forKeyPath:@"blockedLicenseKeys" options:NSKeyValueObservingOptionNew context:nil];
	[productStore addObserver:self forKeyPath:@"publicKey" options:NSKeyValueObservingOptionNew context:nil];
	[productStore addObserver:self forKeyPath:@"numberOfCharactersInDashGroup" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	if (object == productStore) {
		[self updateChangeCount:NSChangeDone];
	}
}

		
- (NSString *)windowNibName;
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController;
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	[productStore setIsLocked:YES];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[archiver encodeObject:productStore];
	[archiver finishEncoding];
	return [data autorelease];
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
	
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
	//[self setProductStore:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	// Customize unarchiver here
	[self setProductStore:[unarchiver decodeObject]];
	[unarchiver finishDecoding];
	[unarchiver release];
	[self updateChangeCount:NSChangeCleared];

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

- (void)dealloc;
{
	[self setProductStore:nil];
	[super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)generateKeys:(id)sender;
{
	[productStore generateKeys];
	[productStore setIsLocked:YES];
}

- (IBAction)generateLicenseKey:(id)sender;
{
	NSString *name = [licenseNameTextField stringValue];
	NSString *key = [productStore generateLicenseKeyForName:name];
	[licenseKeyTextField setStringValue:key];
	NSString *formatted = [NSString stringWithFormat:@"Licensed to: %@\nLicense key: %@", name, key];
	//NSAttributedString *text = [[[NSAttributedString alloc] initWithString:formatted] autorelease];
	//[[formattedLicenseTextView textStorage] setAttributedString:text];
	[[formattedLicenseTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[formattedLicenseTextView textStorage] length]) withString:formatted];
}

- (IBAction)verifyLicenseKey:(id)sender;
{
	NSString *name = [licenseNameTextField stringValue];
	NSString *key = [licenseKeyTextField stringValue];

	NSAlert *alert;

	if ([[productStore ellipticLicense] isBlockedLicenseKey:key]) {
		alert = [NSAlert alertWithMessageText:@"Blocked key" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"This key is blocked."];
		[alert setIcon:[NSImage imageNamed:@"InvalidKey"]];
		[alert setAlertStyle:NSCriticalAlertStyle];
	}
	else {
		if ([[productStore ellipticLicense] verifyLicenseKey:key forName:name]) {
			alert = [NSAlert alertWithMessageText:@"Valid key" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"This key is valid."];
			[alert setIcon:[NSImage imageNamed:@"ValidKey"]];
		}
		else  {
			alert = [NSAlert alertWithMessageText:@"Invalid key" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"License name or key is invalid!"];
			[alert setIcon:[NSImage imageNamed:@"InvalidKey"]];
		}		
	}
	[alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)showCode:(id)sender;
{
	NSMutableString *code;
	switch ([(NSPopUpButton *)sender selectedTag]) {
		case 0: // Obfuscated Public Key
			code = [NSMutableString stringWithString:[productStore obfuscatedPublicKeyCode]];
			break;
		case 1:
			code = [NSMutableString stringWithString:[productStore blockedLicenseKeysAsCode]];
			break;
		case 2: // Initialization Example
		{
			NSString *curveName;
			switch([productStore curveNameTag]) {
				case 0: curveName = @"ELCurveNameSecp112r1"; break;
				case 1: curveName = @"ELCurveNameSecp128r1"; break;
				case 2: curveName = @"ELCurveNameSecp160r1"; break;
			}
			code = [NSMutableString string];
			[code appendFormat:@"#include \"EllipticLicense.h\"\n\n"
				"// ... somewhere inside a method of your class ... \n"
				"%@\n"
				"%@\n\n"
					"\tEllipticLicense *ellipticLicense = [[EllipticLicense alloc] initWithPublicKey:key curveName:%@];\n", [productStore obfuscatedPublicKeyCode], [productStore blockedLicenseKeysAsCode], curveName];
			if ([[productStore blockedLicenseKeys] count] > 0)
				[code appendString:@"\t[ellipticLicense setBlockedKeys:blockedKeys];\n"];

			[code appendString:@"\n\t// ... check licenses here ...\n\n"
				"\t[ellipticLicense release];\n"];
			break;
		}
		case 3:
		{
			code = [NSMutableString string];
			[code appendFormat:@"<?php\n\n"
			 "// EllipticLicense Project Configuration\n"
			"$curve_name = '%@';\n"
			"$public_key = '%@';\n"
			"$private_key = '%@';\n"
			"$number_chars_in_dash_group = %d;\n"
			"$output_format = \"Licensed to: {#name}\\nLicense key: {#key}\\n\";\n"
			"\n"
			"// Server configuration\n"
			"$elgen_path = './'; // path to elgen utility with trailing slash. Make blank it it's in PATH\n"
			"$output_errors = false;\n"
			"\n"
			"?>\n", [productStore curveName], [productStore publicKey], [productStore privateKey], [productStore numberOfCharactersInDashGroup]];
			break;
		}
	}
	[[codeTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[codeTextView textStorage] length]) withString:code];	
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem;
{
	if (![productStore isLocked]) {
		[productStore setIsLocked:YES];
		[[NSSound soundNamed:@"Tink"] play];
		//[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if ([[tabViewItem identifier] isEqualToString:@"Code"])
		[self showCode:codePopUpButton];
}

- (IBAction)addBlockedKey:(id)sender;
{
	[blockKeyTextField setStringValue:@""];
	[NSApp beginSheet:blockKeyWindow modalForWindow:[sender window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}


- (IBAction)closeBlockKeySheet:(id)sender;
{
	[NSApp endSheet:blockKeyWindow];
	[blockKeyWindow orderOut:self];
}
																		  
- (IBAction)doAddBlockedKey:(id)sender;
{
	NSString *key = [blockKeyTextField stringValue];
	if (!key || [key length] == 0) {
		NSBeep();
		[self closeBlockKeySheet:self];
		return;
	}
	
	NSMutableDictionary *blockDict = [NSMutableDictionary dictionary];
	[blockDict setObject:key forKey:@"key"];
	[blockDict setObject:[[productStore ellipticLicense] hashStringOfLicenseKey:key] forKey:@"hash"];
	
	[blockedKeysController addObject:blockDict];
	
	[self closeBlockKeySheet:self];
}

@end
