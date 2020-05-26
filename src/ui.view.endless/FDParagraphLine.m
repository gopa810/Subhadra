//
//  FDParagraphLine.m
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import "FDParagraphLine.h"

@implementation FDParagraphLine

-(id)init
{
	self = [super init];
	if (self) {
		[self initInstance];
	}
	return self;
}

-(id)initWithParagraph:(FDParagraph *)par
{
	self = [super init];
	if (self) {
		[self initInstance];
		self.parent = par;
	}
	return self;
}


-(void)initInstance
{
	self.startOffsetX = 0;
	self.startOffsetY = 0;
	self.height = 0;
	self.width = 0;
	self.topOffsetText = 0;
    self.topOffsetImage = 0;
	self.bottomOffset = 0;
	self.orderNo = 0;
	self.parts = [[NSMutableArray alloc] init];
}

-(float)topOffset
{
    return MAX(self.topOffsetImage, self.topOffsetText);
}

-(void)mergeTopText:(float)top
{
	if (top > self.topOffsetText) {
		self.topOffsetText = top;
	}
}

-(void)mergeTopImage:(float)top
{
    if (top > self.topOffsetImage) {
        self.topOffsetImage = top;
    }
}

-(void)mergeBottom:(float)bottom
{
	if (bottom < self.bottomOffset) {
		self.bottomOffset = bottom;
	}
}


@end
