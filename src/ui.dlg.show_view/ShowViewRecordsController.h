//
//  ShowViewRecordsController.h
//  VedabaseB
//
//  Created by Peter Kollath on 04/11/14.
//
//

#import <UIKit/UIKit.h>
#import "EndlessTextView.h"
#import "VBDialogController.h"
#import "ETVRecords.h"
#import "EndlessTextViewDelegate.h"
#import "HeaderBar.h"
#import "EndlessListViewController.h"

@class EndlessScrollView;

@interface ShowViewRecordsController : VBDialogController <EndlessTextViewDelegate>


@property IBOutlet UILabel * titleLabel;
@property (nonatomic) ETVRecords * source;
@property int userInteractedRecordId;
@property IBOutlet HeaderBar * topBar;
@property IBOutlet HeaderBar * bottomBar;
@property IBOutlet EndlessScrollView * textView;

-(IBAction)onCloseButton:(id)sender;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)delegate;
-(void)setCurrentRecord:(int)recId;

@end
