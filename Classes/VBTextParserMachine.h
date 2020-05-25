//
//  VBTextParserMachine.h
//  VedabaseA2
//
//  Created by Peter Kollath on 8/13/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kStateMachineModePlain 1
#define kStateMachineModeHtml 2

#define kStateMachineInitialStatus 0
#define kStateMachineWordStatus 1
#define kStateMachineNumberStatus 2

#define kStateEventNull 0
#define kStateEventWordBegin 1
#define kStateEventWordEnd 2
#define kStateEventNumberBegin 3
#define kStateEventNumberEnd 4

@interface VBTextParserMachine : NSObject {

	NSCharacterSet * hyphenSet;
	NSCharacterSet * apoSet;
	NSMutableString * string;
	NSInteger status;
	NSInteger mode;
}

-(void)reset;
-(NSInteger)setCharacter:(unichar)chr;
-(NSString *)stringValue;

@end
