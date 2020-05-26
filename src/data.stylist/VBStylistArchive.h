//
//  VBStylistArchive.h
//  Vedabase Styles Builder
//
//  Created by Peter Kollath on 12/2/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBStylistArchive : NSObject

@property (nonatomic,strong) NSDictionary * images;
@property (nonatomic,strong) NSDictionary * texts;
@property NSDictionary * colors;
@property NSDictionary * styles;

-(id)initWithData:(NSData *)data;
-(UIImage *)imageForName:(NSString *)str;
-(NSData *)imageDataForName:(NSString *)str;
-(NSData *)textForName:(NSString *)strName;
-(UIColor *)colorForName:(NSString *)strName;
-(BOOL)loadData:(NSData *)data;



@end
