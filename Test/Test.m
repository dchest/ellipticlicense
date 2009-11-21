#import <Foundation/Foundation.h>
#import "EllipticLicense.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSLog(@"Hello, World!");
	
	
//	NSString *publicKey = @"048049FABC0721B04AA24A1146D72286D120D7278604E8891ED3BF6DE8";
//	NSString *privateKey = @"3081C6020101040E0392C3CA6FC55D0BD0A163E2907EA0818E30818B020101301A06072A8648CE3D0101020F00DB7C2ABF62E35E668076BEAD208B3037040EDB7C2ABF62E35E668076BEAD2088040E659EF8BA043916EEDE8911702B2203150000F50B028E4D696E676875615175290472783FB1041D0409487239995A5EE76B55F9C2F098A89CE5AF8724C0A23E0E0FF77500020F00DB7C2ABF62E35E7628DFAC6561C5020101A120031E00048049FABC0721B04AA24A1146D72286D120D7278604E8891ED3BF6DE8";
	//EllipticLicense *el = [[EllipticLicense alloc] initWithPublicKey:publicKey privateKey:privateKey];
	//[el logKeys];

	EllipticLicense *el = [[EllipticLicense alloc] init];
	[el setCurveName:ELCurveNameSecp160r1];
	if (![el generateKeys])
		NSLog(@"not generated");
	[el logKeys];
	
	NSString *licenseKey = [el licenseKeyForName:@"Test name"];
	NSLog(@"\nLicense (%d): %@", [licenseKey length], licenseKey);
	NSString *p = [el publicKey];
	[el release];
	
	el = [[EllipticLicense alloc] initWithPublicKey:p curveName:ELCurveNameSecp160r1];
	//licenseKey = [licenseKey stringByAppendingString:@"BABBA"];
	if ([el verifyLicenseKey:licenseKey forName:@"Test name"])
		NSLog(@"License VALID.");
	else
		NSLog(@"License invalid!");
	[el release];
	
    [pool drain];
    return 0;
}
