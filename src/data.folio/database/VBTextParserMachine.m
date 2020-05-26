//
//  VBTextParserMachine.m
//  VedabaseA2
//
//  Created by Peter Kollath on 8/13/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "VBTextParserMachine.h"


@implementation VBTextParserMachine

-(id)init
{
	self = [super init];
	
	if (self)
	{
		NSString * hyphenChars = [NSString stringWithFormat:@"-%C%C%C", (unichar)0x2012, (unichar)0x2013, (unichar)0x2014];
		NSString * apoChars = [NSString stringWithFormat:@"%C", (unichar)0x027];
		hyphenSet = [NSCharacterSet characterSetWithCharactersInString:hyphenChars];
		apoSet = [NSCharacterSet characterSetWithCharactersInString:apoChars];
		string = [[NSMutableString alloc] init];
		status = kStateMachineInitialStatus;
		mode = kStateMachineModePlain;
	}
	
	return self;
}

-(void)reset
{
	[string setString:@""];
	status = kStateMachineInitialStatus;
}

#define FTD_ALPHA 1
#define FTD_NUM    2
#define FTD_UNDER 3
#define FTD_AT       4
#define FTD_HYPHEN 5
#define FTD_DOT       6
#define FTD_APO       7
#define FTD_COLON  8
#define FTD_OTHER  9

-(int)indexerCharType:(unichar)rc
{
	if ([[NSCharacterSet letterCharacterSet] characterIsMember:rc])
		return FTD_ALPHA;
	else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:rc])
		return FTD_NUM;
	else if (rc == '_')
		return FTD_UNDER;
	else if (rc == '@')
		return FTD_AT;
	else if (rc == '.')
		return FTD_DOT;
	else if (rc == ',')
		return FTD_COLON;
	else if ([hyphenSet characterIsMember:rc])
		return FTD_HYPHEN;
	else if ([apoSet characterIsMember:rc])
		return FTD_APO;
	else 
		return FTD_OTHER;
	
}

-(NSInteger)setCharacter:(unichar)chr
{
	NSInteger event = kStateEventNull;
	NSInteger type = [self indexerCharType:chr];
	if (status == kStateMachineInitialStatus)
	{
		if (type == FTD_ALPHA || type == FTD_UNDER)
		{
			[string appendFormat:@"%C", chr];
			status = kStateMachineWordStatus;
			event = kStateEventWordBegin;
		}
		else if (type == FTD_NUM)
		{
			[string appendFormat:@"%C", chr];
			status = kStateMachineNumberStatus;
			event = kStateEventNumberBegin;
		}
		else 
		{
			status = kStateMachineInitialStatus;
		}
	}
	else if (status == kStateMachineWordStatus)
	{
		if (type == FTD_ALPHA || type == FTD_NUM || type == FTD_UNDER ||
			type == FTD_AT || type == FTD_APO)
		{
			[string appendFormat:@"%C", chr];
		}
		else
		{
			status = kStateMachineInitialStatus;
			event = kStateEventWordEnd;
		}
	}
	else if (status == kStateMachineNumberStatus)
	{
		if (type == FTD_ALPHA || type == FTD_NUM || type == FTD_UNDER ||
			type == FTD_AT || type == FTD_APO || type == FTD_HYPHEN || type == FTD_DOT)
		{
			[string appendFormat:@"%C", chr];
		}
		else
		{
			status = kStateMachineInitialStatus;
			event = kStateEventNumberEnd;
		}
	}
	
	return event;
}

-(NSString *)stringValue
{
	return string;
}

@end
