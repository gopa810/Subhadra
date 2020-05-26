//
//  VBUserColors.m
//  VedabaseA
//
//  Created by Gopal on 4.6.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VBUserColors.h"


@implementation VBUserColors


+(void)saveUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
}

+(void)loadUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:@"ffffff", @"body_bkg",
								 @"ffffff", @"sel_fore", @"4f36fd", @"sel_bkg", nil];
	
    [defaults registerDefaults:appDefaults];	
}

+(NSString *)colorString:(NSString *)colorName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSLog(@"objectForKey: 8\n");
	return [defaults objectForKey:colorName];
}

+(UIColor *)color:(NSString *)colorName
{
	//NSLog(@"objectForKey: 9\n");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [VBUserColors stringToColor:[defaults objectForKey:colorName]];
}

+(void)setColor:(UIColor *)colorVal withName:(NSString *)name
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[VBUserColors colorToString:colorVal] forKey:name];
}

+(UIColor *)stringToColor:(NSString *)strAttrVal
{
	if ([strAttrVal compare:@"red"] == NSOrderedSame) return [UIColor redColor];
	else if ([strAttrVal compare:@"blue"] == NSOrderedSame) return [UIColor blueColor];
	else if ([strAttrVal compare:@"green"] == NSOrderedSame) return [UIColor greenColor];
	else if ([strAttrVal compare:@"magenta"] == NSOrderedSame) return [UIColor magentaColor];
	else if ([strAttrVal compare:@"yellow"] == NSOrderedSame) return [UIColor yellowColor];
	else if ([strAttrVal compare:@"cyan"] == NSOrderedSame) return [UIColor cyanColor];
	else if ([strAttrVal compare:@"white"] == NSOrderedSame) return [UIColor whiteColor];
	else if ([strAttrVal compare:@"black"] == NSOrderedSame) return [UIColor blackColor];
	else {
		NSScanner * scan = [NSScanner scannerWithString:strAttrVal];
		unsigned val = 0;
		[scan scanHexInt:&val];
		return [UIColor colorWithRed:(((val & 0xff0000) >> 16) / 255.0)
											   green:(((val & 0xff00) >> 8) / 255.0)
												blue:((val & 0xff) / 255.0)
										alpha:1.0];
	}
	
	return nil;
}

+(NSString *)colorToString:(UIColor *)color
{
	int nRed, nBlue, nGreen;

	@try {
		int nc = (int)CGColorGetNumberOfComponents(color.CGColor);
		const CGFloat * cmp = CGColorGetComponents(color.CGColor);
		nRed = nGreen = nBlue = 0.0;
		if (nc == 4)
		{
			nRed   = cmp[0]*255;
			nBlue  = cmp[2]*255;
			nGreen = cmp[1]*255;
		}
		else if (nc == 5)
		{
			nRed = 255-cmp[0]*255;
			nGreen = 255-cmp[1]*255;
			nBlue = 255-cmp[2]*255;
		}
		return [NSString stringWithFormat:@"%02x%02x%02x", nRed, nGreen, nBlue];
	}
	@catch (NSException * e) {
	}
	@finally {
	}
	
	return @"";
}

@end
