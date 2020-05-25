//
//  PopupDialogEx.m
//  VedabaseB
//
//  Created by Peter Kollath on 4/25/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "PopupDialogEx.h"
#import "VBMainServant.h"

@interface PopupDialogEx ()

@end

@implementation PopupDialogEx

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setting the custom images
    [shadowBottom setImage:[VBMainServant imageForName:@"shadow1_bottom"]];
    [shadowTop setImage:[VBMainServant imageForName:@"shadow1_top"]];
    [self.view setBackgroundColor:[VBMainServant colorForName:@"background_yellow"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark control flow management

-(IBAction)done:(id)sender
{
    [self.delegate popupDialogControllerDidFinish:self];
}

-(void)setHtmlText:(NSString *)strHtml
{
    [webView loadHTMLString:strHtml baseURL:[VBMainServant fakeURL]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"--did finish load-");
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"--did fail load - %@", error);
}

@end
