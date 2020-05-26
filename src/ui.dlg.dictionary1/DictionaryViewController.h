//
//  DictionaryViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import <UIKit/UIKit.h>
#import "VBDialogController.h"
#import "EndlessTextViewDelegate.h"
#import "EndlessListViewController.h"

@class ETVRawSource;
@class VBSkinManager, EndlessScrollView;
@class VBFolioStorage;

@interface DictionaryViewController : VBDialogController<UITextFieldDelegate,EndlessTextViewDelegate>

@property VBFolioStorage * storage;
@property VBSkinManager * skinManager;
@property IBOutlet UITextField * textField;
@property ETVRawSource * source;
@property NSArray * dictionaries;
@property IBOutlet EndlessScrollView * textView;
@property IBOutlet UIView * searchBanner;

-(IBAction)onCloseDialog:(id)sender;
-(IBAction)onClearText:(id)sender;

@end
