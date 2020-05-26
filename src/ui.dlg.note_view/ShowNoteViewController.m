//
//  ShowNoteViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "ShowNoteViewController.h"
#import "TGTouchArea.h"
#import "VBMainServant.h"

@interface ShowNoteViewController ()

@end

@implementation ShowNoteViewController

@synthesize popupWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        p_recordId = 0;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotifyRecordNoteChanged object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyRecordNoteChanged object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:kNotifyRecordNoteChanged])
    {
        [self.popupWebView loadHTMLString:[note.userInfo valueForKey:@"htmlText"] baseURL:[VBMainServant fakeURL]];
    }
}

-(IBAction)onCloseButton:(id)sender
{
    [self closeDialog];
}

- (IBAction)onButtonEdit:(id)sender {
    NSDictionary * userInfoDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:p_recordId] forKey:@"record"];
    
    [self.delegate executeTouchCommand:@"editNote" data:userInfoDict];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCmdEditNote
//                                                        object:self
//                                                      userInfo:userInfoDict];
}

-(void)onTabButtonPressed:(id)sender
{
    self.view.alpha = 0.5;
}

-(void)onTabButtonReleased:(id)sender
{
    [self hideDialog];
    self.view.alpha = 1.0;
    [self closeDialog];
}

-(void)onTabButtonReleasedOut:(id)sender
{
    self.view.alpha = 1.0;
}

-(void)setNoteRecordId:(uint32_t)recId
{
    p_recordId = recId;
    self.btnEdit.hidden = NO;
}



@end
