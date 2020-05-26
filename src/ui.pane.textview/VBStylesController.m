//
//  VBStylesController.m
//  VedabaseA
//
//  Created by Gopal on 25.9.2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VBStylesController.h"
#import "VBUserColors.h"

@implementation VBStylesController

@synthesize bodyStyleDataBuff;
@synthesize styles;
@synthesize fileName;
@synthesize cssFileName;

-(id)init
{
	if (self = [super init])
	{
		bModified = FALSE;
		self.fileName = nil;
		self.styles = [[NSMutableArray alloc] init];
		//[arr release];

	}

	return self;

}

-(id)initWithFile:(NSString *)fname
{
	if ([self init])
	{
		[self loadStyles:fname];
	}
	return self;
}

-(void)setStylesModified
{
	bModified = TRUE;
	self.bodyStyleDataBuff = nil;
}

-(void)applyChanges:(id)sender
{
	if (bModified)
	{
		[self saveStyles];
		[self exportStylesToFile:self.cssFileName];
	}
	bModified = NO;
}

-(void)loadStyles:(NSString *)fName
{
	self.fileName = fName;
	NSArray * arr = [NSArray arrayWithContentsOfFile:fName];
	for(NSDictionary * item in arr)
	{
		NSMutableDictionary * origFormat = [[NSMutableDictionary alloc] initWithDictionary:[item objectForKey:@"format"]];
		NSMutableDictionary * md = [[NSMutableDictionary alloc] initWithDictionary:item];
		[md setObject:origFormat  forKey:@"format"];
		[styles addObject: md];
		//[md release];
		//[origFormat release];
	}
}

-(void)saveStyles
{
	if (self.fileName == nil) return;
	if (bModified)
	{
		[styles writeToFile:self.fileName atomically:YES];
		bModified = NO;
	}
}


-(void)exportStylesToFile:(NSString *)exportName
{		
	NSMutableString * mstr = [[NSMutableString alloc] initWithCapacity:10000];	
	NSDictionary * pItem;
	
		NSLog(@"***********save style sheets************\n");
	[mstr setString:@"\n"];
	for(NSDictionary * oneStyle in styles)
	{
		NSString * styleName = [oneStyle objectForKey:@"name"];
		/*if ([styleName isEqual:@"Verse-Section"])
			NSLog(@"Regenerated style is: %@", oneStyle);*/
		if (styleName && [styleName isEqual:@"iFolio-Default-Body"])
		{
			NSDictionary * dict = [oneStyle objectForKey:@"format"];
			self.bodyStyleDataBuff = [NSString stringWithFormat:@"font-family:%@;font-size:%@;", 
									  [dict objectForKey:@"font-family"],
									  [dict objectForKey:@"font-size"]];
		}
		if (styleName)
		{
			[mstr appendFormat:@".%@ {\n", styleName];
		
			pItem = [oneStyle objectForKey:@"format"];
			if (pItem == nil)
				continue;
			
			NSEnumerator * keyEnum = [pItem keyEnumerator];
			id key;
			while ((key = [keyEnum nextObject])) 
			{
				NSString * strKey = (NSString *)key;
				id idVal = [pItem objectForKey:strKey];
				[mstr appendFormat:@"\t%@:%@;\n", strKey, idVal];
			}
			[mstr appendFormat:@"}\n\n"];
			//[keyEnum release];
		}
	}

	[mstr appendFormat:@"\nbody {\nbackground-color:#%@;%@\n}\n\n.FolioFoundText {\nbackground-color:#%@;\ncolor:#%@;\n}\n",
					   [VBUserColors colorString:@"body_bkg"], 
					self.bodyStyleDataBuff,
						[VBUserColors colorString:@"sel_bkg"],
					   [VBUserColors colorString:@"sel_fore"]];
	
	NSLog(@"Styles:\n%@\n", mstr);
	[mstr writeToFile:exportName atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	//[mstr release];
}

@end
