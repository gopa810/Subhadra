//
//  SearchAdvancedDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/4/14.
//
//

#import <UIKit/UIKit.h>
#import "VBDialogController.h"
#import "SearchKeyboardAccessoryView.h"
#import "VBQueryTemplate.h"
#import "VBUserQuery.h"

@class VBMainServant;
@class VBSearchManager;
@class CIModel;

@interface SearchAdvancedDialog : VBDialogController
{
    int currentQueryIndex;
    int currentScopeIndex;
    NSMutableArray * queries;
    VBQueryTemplate * tempTemplate;
}

@property (retain, nonatomic) IBOutlet UILabel *dialogTitleLabel;
@property (assign, nonatomic) id delegateSearch;
@property VBMainServant * mainServant;

@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (retain, nonatomic) IBOutlet UIButton *buttonPrevious;
@property (retain, nonatomic) IBOutlet UIButton *buttonNext;
@property IBOutlet UIImageView * explainImageView;
@property IBOutlet UIScrollView * explainScrollView;
@property (nonatomic, retain) SearchKeyboardAccessoryView * keyboardAccessoryViewController;
@property (nonatomic, retain) VBQueryTemplate * queryTemplate;

@property (retain, nonatomic) IBOutlet UIView *templateInfoPane;
@property (retain, nonatomic) IBOutlet UILabel *templateNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *scopeNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *finalQueryLabel;

@property IBOutlet UIButton * buttonChooseTemplate;
@property IBOutlet UIButton * buttonChooseScope;

@property VBSearchManager * searchManager;
@property CIModel * folioContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil template:(VBQueryTemplate *)templ;
- (IBAction)onTextFieldValueChanged:(id)sender;
- (VBUserQuery *)finalQuery;
- (IBAction)onChooseTemplate:(id)sender;
- (IBAction)onChooseScope:(id)sender;

@end
