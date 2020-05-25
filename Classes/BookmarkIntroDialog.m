//
//  BookmarkIntroDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import "BookmarkIntroDialog.h"
#import "GetUserStringDialog.h"
#import "BookmarksEditorDialog.h"
#import "VBMainServant.h"

@interface BookmarkIntroDialog ()

@end

@implementation BookmarkIntroDialog
@synthesize recordId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [VBMainServant colorForName:@"dark_papyrus"];
        self.touchArea.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.touchArea.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setTouchArea:nil];
    [self setModeSwitchButton:nil];
    [super viewDidUnload];
}
- (IBAction)onCancel:(id)sender {
    [self closeDialog];
}

- (IBAction)onBookmarkAdd:(id)sender {
    
    GetUserStringDialog * dlg = [[GetUserStringDialog alloc] initWithNibName:@"GetUserStringDialog" bundle:nil];
    
    dlg.delegate = self.delegate;
    [self.view.superview addSubview:dlg.view];
    self.view.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:([self.modeSwitchButton isOn]? 1 : 0) forKey:@"use_bookmark_wizard"];
    [self closeDialog];
}

- (IBAction)onGotoBookmark:(id)sender {
    BookmarksEditorDialog * dlg = [[BookmarksEditorDialog alloc] initWithNibName:@"BookmarksEditorDialog" bundle:nil mode:1];
    
    dlg.recordId = self.recordId;
    dlg.delegate = self.delegate;
    [self.view.superview addSubview:dlg.view];
    self.view.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:([self.modeSwitchButton isOn]? 1 : 0) forKey:@"use_bookmark_wizard"];
    [self closeDialog];
}

- (IBAction)onBookmarkUpdate:(id)sender {
    BookmarksEditorDialog * dlg = [[BookmarksEditorDialog alloc] initWithNibName:@"BookmarksEditorDialog" bundle:nil mode:2];
    
    dlg.recordId = self.recordId;
    dlg.delegate = self.delegate;
    [self.view.superview addSubview:dlg.view];
    self.view.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:([self.modeSwitchButton isOn]? 1 : 0) forKey:@"use_bookmark_wizard"];
    [self closeDialog];
}
@end
