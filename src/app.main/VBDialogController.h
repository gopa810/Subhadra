//
//  VBDialogController.h
//  VedabaseB
//
//  Created by Peter Kollath on 06/09/14.
//
//

#import <UIKit/UIKit.h>

@class VBUserInterfaceManager;

@interface VBDialogController : UIViewController

@property VBUserInterfaceManager * delegate;
@property CGFloat transitionDiff;
@property CGSize transitionOff;
@property int transitionMode;

-(void)setTransitionDifference:(CGFloat)diff;
-(void)setTransitionOffset:(CGSize)size;

-(void)showDialog;
-(void)hideDialog;
-(void)openDialog;
-(void)closeDialog;

@end
