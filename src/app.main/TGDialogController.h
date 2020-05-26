//
//  TGDialogController.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"

@class VBUserInterfaceManager;

@interface TGDialogController : UIViewController<TGTabBarTouches>

@property (nonatomic, retain) id<TGTabBarTouches> messageDelegate;
//@property VBUserInterfaceManager * userInterfaceManager;

-(void)showDialog;
-(void)hideDialog;
-(void)closeDialog;

@end
