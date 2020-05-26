//
//  EndlessParagraphViewCell.m
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import "EndlessParagraphViewCell.h"
#import "Canvas.h"
#import "FDRecordBase.h"
#import "FDRecordPart.h"
#import "FDColor.h"

@implementation EndlessParagraphViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    BOOL savedState = NO;
    CGFloat yCurr = 0;
    Canvas * canvas = [[Canvas alloc] init];
    CGFloat width = rect.size.width - self.drawer.paddingRight - self.drawer.paddingLeft;

    if (self.record.recordMark != nil) {
        if (!savedState)
            CGContextSaveGState(canvas.context);
        [canvas setFillColor:self.drawer.recordMarkColor];
        [self.record.recordMark drawAtPoint:CGPointMake(8, yCurr + 2)
                             withAttributes:self.drawer.recordMarkAttributes];
        savedState = YES;
    }
    if (savedState) {
        CGContextRestoreGState(canvas.context);
        savedState = NO;
    }
    
    self.record.recordPaintOffset = yCurr;
    
    if (self.record.loading) {
    } else if ([self.record.parts count] > 0) {
        //Log.i("drawpane", "drawing -OK- record");
        float x = self.drawer.paddingLeft;
        float y = yCurr;
        int order = 0;

        // draw note icon only if not interferring with history buttons
        if (y > 64 && self.notes.noteText && ([self.notes.noteText length] > 0)) {
            [canvas drawImage:[self.drawer.skinManager endlessTextViewRecordNoteImage]
                         rect:CGRectMake(10, y+4, 32, 32)];
            self.record.noteIcon = true;
        }
        
        /*if ([self.dataSource recordHasBookmark:record.recordId])
         {
         [canvas drawImage:[self.skinDelegate endlessTextViewBookmarkImage]
         rect:CGRectMake(width + self.paddingLeft + 10, yCurr + 4, 32, 32)];
         }*/
        
        FDHighlightTracker * tracker = nil;
        
        if (self.notes && self.notes.anchorsCount > 0)
        {
            tracker = [[FDHighlightTracker alloc] init];
            tracker.charCounter = 0;
            tracker.notes = self.notes;
            tracker.highlighterIndex = 0;
            tracker.anchor = [self.notes anchorAtIndex:0];
        }
        
        canvas.orderedPoints = self.selection.orderedPoints;
        canvas.anchor = tracker;
        canvas.phrases = self.drawer.highlightPhrases;
        
        for (FDRecordPart * rp in self.record.parts) {
            if (rp.delegate == nil)
                rp.delegate = self.drawer.skinManager;
            rp.orderNo = order;
            rp.absoluteTop = y;
            rp.absoluteRight = rect.size.width;
            
            //CGSize imageSize = CGSizeMake(width, rp.calculatedHeight);
            //NSLog(@"Making imageSHot from record part %d.%d %f", record.recordId, rp.orderNo, rp.calculatedHeight);
            //UIGraphicsBeginImageContext(imageSize);
            //Canvas * privCanvas = [[Canvas alloc] init];
            //[rp drawWithCanvas:privCanvas
            //            xstart:0
            //            ystart:0
            //            points:self.orderedPoints
            //            anchor:tracker
            //           phrases:self.highlightPhrases];
            //UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            //rp.imageShot = image;
            //UIGraphicsEndImageContext();
            
            y += [rp drawWithCanvas:canvas
                             xstart:x
                             ystart:y];
            
            //rp.draw(canvas, x, y, orderedPoints, anch);
            rp.absoluteBottom = y;
            order++;
        }
        
        if (self.selection.currentRecordLeftHighlighter == self.record.recordId)
        {
            CGContextSaveGState(canvas.context);
            CGRect highlightedBox = CGRectMake(0, yCurr, self.drawer.paddingLeft, y - yCurr);
            [canvas setFillColor:[FDColor getColor:0x7f663300]];
            [canvas fillRect:highlightedBox];
            CGContextRestoreGState(canvas.context);
        }
        else if (self.selection.currentRecordRightHighlighter == self.record.recordId)
        {
            CGContextSaveGState(canvas.context);
            CGRect highlightedBox = CGRectMake(width + self.drawer.paddingLeft, yCurr, self.drawer.paddingRight, y - yCurr);
            [canvas setFillColor:[FDColor getColor:0x7f663300]];
            [canvas fillRect:highlightedBox];
            CGContextRestoreGState(canvas.context);
        }
    }

}



@end
