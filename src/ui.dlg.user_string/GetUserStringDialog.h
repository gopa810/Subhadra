//
//  BookmarkAddNewDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import "TGTouchArea.h"
#import "VBFolio.h"
#import "VBDialogController.h"
#import "GetUserStringDelegate.h"
#import "HeaderBar.h"

@interface GetUserStringDialog : VBDialogController
{
    VBFolio * folio;
    NSString * t1;
    NSString * t2;
}

@property id<GetUserStringDelegate> callbackDelegate;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet HeaderBar *touchBack;
@property (retain, nonatomic) IBOutlet UITextField *textField;
@property IBOutlet UILabel * labelTitle;
@property IBOutlet UILabel * labelSubtitle;

@property NSDictionary * userInfo;
@property NSString * tag;


- (IBAction)onEditingDidEnd:(id)sender;

- (IBAction)onSave:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onTextFieldChanged:(id)sender;

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
