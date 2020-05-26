//
//  ShowNoteViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import <UIKit/UIKit.h>
#import "TGTouchArea.h"
#import <WebKit/WebKit.h>
#import "VBDialogController.h"

@interface ShowNoteViewController : VBDialogController <TGTabBarTouches>
{
    uint32_t p_recordId;
}

@property (nonatomic,retain) IBOutlet WKWebView * popupWebView;
@property (retain, nonatomic) IBOutlet UIButton *btnEdit;


-(IBAction)onCloseButton:(id)sender;
- (IBAction)onButtonEdit:(id)sender;
-(void)setNoteRecordId:(uint32_t)recId;

@end
