//
//  SelectUserStringDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 21/11/14.
//
//

#import "VBDialogController.h"
#import "SelectUserStringTableController.h"
#import "SelectUserStringDelegate.h"

@interface SelectUserStringDialog : VBDialogController
{
    NSArray * _strings;
}

@property id<SelectUserStringDelegate> callbackDelegate;
@property IBOutlet SelectUserStringTableController * tableController;
@property IBOutlet UILabel * titleLabel;
@property IBOutlet UIView * headerBack;
@property IBOutlet UITableView * tableView;

@property NSString * tag;
@property NSDictionary * userInfo;

@property NSArray * strings;

-(IBAction)onClose:(id)sender;
-(IBAction)onCancel:(id)sender;
-(void)setDialogTitle:(NSString *)strTitle;

@end
