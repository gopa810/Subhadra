//
//  FDHighlightTracker.h
//  VedabaseB
//
//  Created by Peter Kollath on 15/08/14.
//
//

#import <Foundation/Foundation.h>
#import "VBHighlighterAnchor.h"
#import "VBRecordNotes.h"

@interface FDHighlightTracker : NSObject

@property VBRecordNotes * notes;
@property int charCounter;
@property int highlighterIndex;


@property VBHighlighterAnchor * anchor;


-(void)nextAnchor;

@end
