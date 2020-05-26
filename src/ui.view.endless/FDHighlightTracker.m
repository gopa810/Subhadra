//
//  FDHighlightTracker.m
//  VedabaseB
//
//  Created by Peter Kollath on 15/08/14.
//
//

#import "FDHighlightTracker.h"

@implementation FDHighlightTracker


-(void)nextAnchor
{
    self.highlighterIndex ++;
    self.anchor = [self.notes anchorAtIndex:self.highlighterIndex];
}

@end
