//
//  VBContentItem.h
//  VedabaseA
//
//  Created by Gopal on 25.5.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CIBase.h"
#import "CIBack.h"
#import "CITitle.h"
#import "VBFolio.h"

@interface CIModel : CIBase

@property (strong) NSNumber * hits;
@property BOOL hasChild;
@property (strong) NSString * nodeCode;
@property int nodeType;
@property NSArray * richText;
@property UIImage * iconImage;
@property NSString * iconName;

+(CIModel *)contentItem:(VBFolioContentItem *)s;
-(void)incrementHits;
-(void)clearHits;
-(NSString *)listOfSelectedItems;
+(void)getChildren:(int)recordId array:(NSMutableArray *)arr folio:(VBFolio *)folio;

@end

