//
//  VBHtmlElementsParserMachine.m
//  VedabaseA2
//
//  Created by Peter Kollath on 8/14/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBHtmlElementsParserMachine.h"


@implementation VBHtmlElementsParserMachine


@synthesize tagNameAvailable;
@synthesize paramNameAvailable;
@synthesize paramValueAvailable;
@synthesize charAvailable;
@synthesize charStart;
@synthesize charEnd;
@synthesize tagStart, tagEnd;

-(id)init
{
	self = [super init];
	
	if (self)
	{
		status = 0;
		tagNameAvailable = NO;
		charAvailable = NO;
		unicodeChar = 0;
		string = [[NSMutableString alloc] init];
	}
	
	return self;
}

-(NSInteger)setChar:(char)rc
{
	charAvailable = NO;
	tagNameAvailable = NO;
	paramNameAvailable = NO;
	paramValueAvailable = NO;
	charStart = charEnd = NO;
	tagStart = NO;
	tagEnd = NO;
	
	if (status == 0)
	{
		if (rc == '<')
		{
			status = 1;
			tagStart = YES;
			[string setString:@""];
		}
		else if (rc == '&')
		{
			charStart = YES;
			status = 20;
			[string setString:@""];
		}
		else
		{
			charStart = YES;
			charEnd = YES;
			charAvailable = YES;
			unicodeChar = ((unsigned char)rc);
		}
	}
	else if (status == 1)
	{
		if (isspace(rc))
		{
		}
		else
		{
			[string appendFormat:@"%c", rc];
			status = 2;
		}
	}
	else if (status == 2)
	{
		if (isspace(rc))
		{
			tagNameAvailable = YES;
			status = 3;
		}
		else if (rc == '>')
		{
			tagNameAvailable = YES;
			tagEnd = YES;
			status = 0;
		}
		else if (rc == '/')
		{
			status = 4;
		}
		else
		{
			[string appendFormat:@"%c", rc];
		}
	}
	else if (status == 3)
	{
		if (isspace(rc))
		{
		}
		else if (rc == '>')
		{
			tagEnd = YES;
			status = 0;
		}
		else if (rc == '/')
		{
			status = 4;
		}
		else {
			[string setString:@""];
			[string appendFormat:@"%c", rc];
			status = 5;
		}

	}
	else if (status == 4)
	{
		if (rc == '>')
		{
			tagEnd = YES;
			tagNameAvailable = YES;
			status = 0;
		}
	}
	else if (status == 5)
	{
		if (isspace(rc))
		{
			paramNameAvailable = YES;
			status = 6;
		}
		else if (rc == '/')
		{
			paramNameAvailable = YES;
			status = 4;
		}
		else if (rc == '>')
		{
			tagEnd = YES;
			paramNameAvailable = YES;
			status = 0;
		}
		else if (rc == '=')
		{
			paramNameAvailable = YES;
			status = 7;
		}
		else
		{
			[string appendFormat:@"%c", rc];
		}
	}
	else if (status == 6)
	{
		if (rc == '=')
		{
			status = 7;
		}
		else if (rc == '/')
		{
			status = 4;
		}
		else if (rc == '>')
		{
			tagEnd = YES;
			status = 0;
		}
		else if (isspace(rc))
		{
		}
		else
		{
			[string setString:@""];
			[string appendFormat:@"%c", rc];
			status = 5;
		}
	}
	else if (status == 7)
	{
		if (rc == '\'')
		{
			[string setString:@""];
			status = 9;
		}
		else if (rc == '\"')
		{
			[string setString:@""];
			status = 10;
		}
		else if (rc == '/')
		{
			status = 4;
		}
		else if (rc == '>')
		{
			tagEnd = YES;
			status = 0;
		}
		else if (isspace(rc))
		{
		}
		else
		{
			[string setString:@""];
			[string appendFormat:@"%c", rc];
			status = 8;
		}
	}
	else if (status == 8)
	{
		if (isspace(rc))
		{
			paramValueAvailable = YES;
			status = 5;
		}
		else if (rc == '/')
		{
			paramValueAvailable = YES;
			status = 4;
		}
		else if (rc == '>')
		{
			tagEnd = YES;
			paramValueAvailable = YES;
			status = 0;
		}
		else
		{
			[string appendFormat:@"%c", rc];
		}
	}
	else if (status == 9)
	{
		if (rc == '\\')
		{
			status = 12;
		}
		else if (rc == '\'')
		{
			paramValueAvailable = YES;
			status = 5;
		}
		else 
		{
			[string appendFormat:@"%c", rc];
		}
	}
	else if (status == 10)
	{
		if (rc == '\\')
		{
			status = 11;
		}
		else if (rc == '\"')
		{
			paramValueAvailable = YES;
			status = 5;
		}
		else 
		{
			[string appendFormat:@"%c", rc];
		}
	}
	else if (status == 11)
	{
		[string appendFormat:@"%c", rc];
		status = 10;
	}
	else if (status == 12)
	{
		[string appendFormat:@"%c", rc];
		status = 9;
	}
	else if (status == 20)
	{
		if (rc == '#')
		{
			status = 21;
		}
		else
		{
			status = 22;
		}
	}
	else if (status == 21)
	{
		if (rc == ';')
		{
			unicodeChar = [string intValue];
			charAvailable = YES;
			charEnd = YES;
			status = 0;
		}
		else
		{
			[string appendFormat:@"%c", rc];
		}
	}
	else if (status == 22)
	{
		if (rc == ';')
		{
			status = 0;
			if ([string isEqual:@"nbsp"])
			{
				unicodeChar = 160;
			}
			else if ([string isEqual:@"lt"])
			{
				unicodeChar = 60;
			}
			else if ([string isEqual:@"gt"])
			{
				unicodeChar = 62;
			}
			else if ([string isEqual:@"amp"])
			{
				unicodeChar = 38;
			}
			else if ([string isEqual:@"quot"])
			{
				unicodeChar = 34;
			}
			else if ([string isEqual:@"apos"])
			{
				unicodeChar = 39;
			}
			else if ([string isEqual:@"ndash"])
			{
				unicodeChar = 8211;
			}
			else if ([string isEqual:@"mdash"])
			{
				unicodeChar = 8212;
			}
			else if ([string isEqual:@"lsquo"])
			{
				unicodeChar = 8216;
			}
			else if ([string isEqual:@"rsquo"])
			{
				unicodeChar = 8217;
			}
			else if ([string isEqual:@"sbquo"])
			{
				unicodeChar = 8218;
			}
			else if ([string isEqual:@"rdquo"])
			{
				unicodeChar = 8220;
			}
			else if ([string isEqual:@"ldquo"])
			{
				unicodeChar = 8221;
			}
			else if ([string isEqual:@"bdquo"])
			{
				unicodeChar = 8222;
			}
			charAvailable = YES;
			charEnd = YES;
		}
		else
		{
			[string appendFormat:@"%c", rc];
		}
	}
	
	return 0;
}

-(unichar)unicodeCharacter
{
	return unicodeChar;
}

-(NSString *)stringValue
{
	return string;
}


@end
