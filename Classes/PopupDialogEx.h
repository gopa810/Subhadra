//
//  PopupDialogEx.h
//  VedabaseB
//
//  Created by Peter Kollath on 4/25/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupDialogDelegate;

@interface PopupDialogEx : UIViewController <UIWebViewDelegate>
{
    id <PopupDialogDelegate> delegate;
    IBOutlet UIWebView * webView;
    IBOutlet UIButton * buttonClose;
    IBOutlet UIImageView * shadowTop;
    IBOutlet UIImageView * shadowBottom;
}

@property (nonatomic,assign) id <PopupDialogDelegate> delegate;

-(IBAction)done:(id)sender;

-(void)setHtmlText:(NSString *)strHtml;
@end


@protocol PopupDialogDelegate
-(void)popupDialogControllerDidFinish:(PopupDialogEx *)dialog;
@end
