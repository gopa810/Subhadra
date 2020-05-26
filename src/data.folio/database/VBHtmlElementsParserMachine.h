//
//  VBHtmlElementsParserMachine.h
//  VedabaseA2
//
//  Created by Peter Kollath on 8/14/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VBHtmlElementsParserMachine : NSObject {

	NSInteger status;
	BOOL tagNameAvailable;
	BOOL paramNameAvailable;
	BOOL paramValueAvailable;
	BOOL charAvailable;
	BOOL charStart;
	BOOL charEnd;
	BOOL tagStart;
	BOOL tagEnd;
	unichar unicodeChar;
	NSMutableString * string;
}

@property (assign) BOOL tagNameAvailable;
@property (assign) BOOL paramNameAvailable;
@property (assign) BOOL paramValueAvailable;
@property (assign) BOOL charAvailable;
@property (assign) BOOL charStart;
@property (assign) BOOL charEnd;
@property (assign) BOOL tagStart;
@property (assign) BOOL tagEnd;


-(NSInteger)setChar:(char)rc;
-(unichar)unicodeCharacter;
-(NSString *)stringValue;

@end
