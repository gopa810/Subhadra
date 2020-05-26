//
//  VBLooseView.h
//  VedabaseB
//
//  Created by Peter Kollath on 26/01/15.
//
//

#import <UIKit/UIKit.h>
#import "VBLooseViewDelegate.h"

@interface VBLooseView : UIView

@property IBOutlet id<VBLooseViewDelegate> delegate;
@property NSString * tagString;

@end
