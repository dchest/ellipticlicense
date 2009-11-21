/* Interface for EllipticLicense framework or static library */

extern NSString *ELCurveNameSecp112r1;
extern NSString *ELCurveNameSecp128r1;
extern NSString *ELCurveNameSecp160r1;

@interface EllipticLicense : NSObject

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

- (void)setBlockedLicenseKeyHashes:(NSArray *)hashes;
- (NSArray *)blockedLicenseKeyHashes;
- (BOOL)isBlockedLicenseKey:(NSString *)licenseKey;

- (BOOL)generateKeys;
- (void)logKeys;

- (NSString *)hashStringOfLicenseKey:(NSString *)licenseKey;

- (NSString *)licenseKeyForName:(NSString *)name;
- (BOOL)verifyLicenseKey:(NSString *)signature forName:(NSString *)name;

@end
