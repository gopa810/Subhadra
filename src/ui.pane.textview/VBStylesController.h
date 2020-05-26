//
//  VBStylesController.h
//  VedabaseA
//
//  Created by Gopal on 25.9.2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VBUserColors;

@interface VBStylesController : NSObject {
	BOOL bModified;
	NSString * fileName;
	NSString * cssFileName;


	NSMutableArray * styles;

	
	NSString * bodyStyleDataBuff;
}

@property (nonatomic,retain) NSString * bodyStyleDataBuff;
@property (nonatomic,retain) NSMutableArray * styles;
@property (nonatomic,retain) NSString * fileName;
@property (nonatomic,retain) NSString * cssFileName;


-(void)applyChanges:(id)sender;
-(void)setStylesModified;
-(id)init;
-(id)initWithFile:(NSString *)fname;
-(void)loadStyles:(NSString *)fileName;
-(void)saveStyles;
-(void)exportStylesToFile:(NSString *)exportName;


@end
