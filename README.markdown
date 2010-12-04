EllipticLicense
===============

Short product key generation and validation framework based on elliptic curves digital signatures (ECDSA) for Mac OS X/Cocoa.

Project goal: replacement for AquaticPrime with shorter keys and similar or better security.

*Documentation will be available later... For now, read EllipticLicense.h*

[Watch screencast](http://www.youtube.com/watch?v=lcT8YcbUpg0)

## Example keys

112-bit curve (~ equivalent to RSA-512, 2^56 bit security):

	Licensed to: John Doe
	License key: HQYRV-OZFNZ-M3L7B-WA644-CXLG4-D7IRD-QZ6FY-GJGTO-MEXEG

128-bit curve (2^64 bit security):

	Licensed to: John Doe
	License key: YBFB-L264-32WL-KHK4-DA4L-L7VW-HGCV-PO3U-PFF6-RJHW-MRBS-5OW4-53WA
		
160-bit curve (~ equivalent to RSA-1024, 2^80 bit security):

	Licensed to: John Doe
	License key: IPAA6CH2-2STFJTCW-PYBDDBDM-YK4ZYA6N-3YE624E4-2K7KFDLE-LODJEN5W-WRADC652

## EllipticLicenseDeveloper App


There's a GUI application for managing your project public and private keys, generating licenses and blocking keys called EllipticLicenseDeveloper included.
	

## Requirements

Mac OS X 10.6 (because it includes libcrypto.0.9.8d.dylib, don't forget to link you project with it).	


License
--------

EllipticLicense is licensed under Apache 2 license. See LICENSE. License!


Mailing list
------------

Send email to <ellipticlicense@librelist.com> to subscribe.

* * *

Made by [Coding Robots](http://www.codingrobots.com)
