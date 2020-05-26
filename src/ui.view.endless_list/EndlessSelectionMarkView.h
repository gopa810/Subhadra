//
//  EndlessSelectionMarkView.h
//  VedabaseB
//
//  Created by Peter Kollath on 18/01/15.
//
//

#import <UIKit/UIKit.h>

@interface EndlessSelectionMarkView : UIView

@property UIImage * image;
@property NSString * title;
@property BOOL reverseImage;
@property CGSize hotSpotOffset;
@property CGPoint hotSpotLocation;
@property CGPoint handlePoint;


-(void)setOrigin:(CGPoint)pt;
-(void)setHandleLocation:(CGPoint)pt;

@end
