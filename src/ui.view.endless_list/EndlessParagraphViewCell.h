//
//  EndlessParagraphViewCell.h
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import <UIKit/UIKit.h>
#import "FDRecordBase.h"
#import "VBRecordNotes.h"
#import "FDDrawingProperties.h"
#import "FDSelectionContext.h"

@interface EndlessParagraphViewCell : UITableViewCell


@property FDRecordBase * record;
@property VBRecordNotes * notes;
@property (weak) FDDrawingProperties * drawer;
@property (weak) FDSelectionContext * selection;

@end



