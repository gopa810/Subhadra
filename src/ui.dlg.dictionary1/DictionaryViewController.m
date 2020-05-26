//
//  DictionaryViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 07/11/14.
//
//

#import "DictionaryViewController.h"
#import "VBSkinManager.h"
#import "EndlessTextView.h"
#import "ETVRawSource.h"
#import "VBDictionaryInstance.h"
#import "VBDictionaryMeaning.h"
#import "VBDictionaryWord.h"
#import "VBMainServant.h"
#import "EndlessScrollView.h"

@interface DictionaryViewController ()

@end

@implementation DictionaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.view.backgroundColor = [self.skinManager colorForName:@"headerBackground"];
    [self.textField becomeFirstResponder];
    
    self.storage = [[[VBMainServant instance] currentFolio] firstStorage];
    self.source = [[ETVRawSource alloc] init];
    
    self.textView.dataSource = self.source;
    self.textView.delegate = self;
    self.textView.drawer = [VBMainServant instance].drawer;
    [self.textView setSkin:self.skinManager];
    self.textView.backgroundColor = [self.skinManager colorForName:@"bodyBackground"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:UIDeviceOrientationDidChangeNotification])
    {
        [self.textView rearrangeForOrientation];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onCloseDialog:(id)sender
{
    [self.textField resignFirstResponder];
    [self closeDialog];
}

-(IBAction)onClearText:(id)sender
{
    [self.textField setText:@""];
}

-(NSString *)dictionaryName:(int)dictId
{
    for (VBDictionaryInstance * di in self.dictionaries) {
        if (di.ID == dictId)
            return di.name;
    }
    
    return @"Dictionary";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString * str = self.textField.text;

    [self.textField resignFirstResponder];
    self.searchBanner.hidden = NO;
    [self performSelector:@selector(searchWord:) withObject:str afterDelay:0.1];
    
    return YES;
}


-(void)searchWord:(NSString *)strWord
{
    NSString * str = [strWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange rangeSpace = [str rangeOfString:@" "];
    if (rangeSpace.location != NSNotFound)
    {
        str = [str substringToIndex:rangeSpace.location];
    }
    if (self.dictionaries == nil)
    {
        VBDictionaryInstance * di = [[VBDictionaryInstance alloc] initWithStorage:self.storage];
        self.dictionaries = [di dictionaries];
    }
    [self.source clear];
    if ([str length] < 1)
    {
        [self performSelectorOnMainThread:@selector(showResults:)
                               withObject:nil
                            waitUntilDone:NO];
    }
    
    VBDictionaryWord * word = [[VBDictionaryWord alloc] initWithStorage:self.storage];
    VBDictionaryMeaning * meanings = [[VBDictionaryMeaning alloc] initWithStorage:self.storage];
    
    NSMutableSet * found = [[NSMutableSet alloc] init];
    NSMutableArray * results = [[NSMutableArray alloc] init];
    [word findExactWords:str limit:10 alreadyFound:found results:results];
    [word findWordsWithPrefix:str limit:10 alreadyFound:found results:results];
    [word findWordsContaining:str limit:10 alreadyFound:found results:results];
    
    for(VBDictionaryWord * dw in results)
    {
        [self.source addFlatText:[NSString stringWithFormat:@"<PT:18pt><BD+>%@<BD>", dw.word]];
        int dictId = -1;
        NSArray * meanArr = [meanings findMeaningForWord:dw.ID];
        for (VBDictionaryMeaning * dm in meanArr)
        {
            if (dictId != dm.dictionaryID)
            {
                [self.source addFlatText:[NSString stringWithFormat:@"<PT:10pt><IN:LF:20pt><FC:128,128,128>%@", [self dictionaryName:dm.dictionaryID]]];
                dictId = dm.dictionaryID;
            }
            [self.source addFlatText:[NSString stringWithFormat:@"<PT:12pt><IN:LF:40pt>• %@", dm.meaning]];
        }
    }

    [self performSelectorOnMainThread:@selector(showResults:)
                           withObject:nil
                        waitUntilDone:NO];
}

-(void)showResults:(id)sender
{
    self.searchBanner.hidden = YES;
    self.textView.drawer.highlightPhrases = nil;
    [self.textView setCurrentRecord:0 offset:0];
}

#pragma mark -
#pragma mark Endless Delegate

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        return YES;
    }
    
    return NO;
}

-(void)copy:(id)sender
{
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    
    NSMutableDictionary * newPasteboardContent = [[NSMutableDictionary alloc] init];
    NSData * data = [[self.textView getSelectedText:NO] dataUsingEncoding:NSUTF8StringEncoding];
    [newPasteboardContent setObject:data forKey:@"public.text"];
    
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
}

-(void)endlessTextView:(UIView *)textView leftAreaClicked:(int)recId withRect:(CGRect)rect
{
}

-(void)endlessTextView:(UIView *)textView leftAreaLongClicked:(int)recId withRect:(CGRect)rect
{
}

-(void)endlessTextView:(UIView *)textView navigateLink:(NSDictionary *)data
{
}

-(void)endlessTextView:(UIView *)textView rightAreaClicked:(int)recId withRect:(CGRect)rect
{
}

-(void)endlessTextView:(UIView *)textView rightAreaLongClicked:(int)recId withRect:(CGRect)rect
{
}

-(void)endlessTextView:(UIView *)textView selectionDidChange:(CGRect)rect
{
    [self becomeFirstResponder];
    UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
    [theMenu setMenuVisible:YES animated:YES];
}

-(void)endlessTextView:(UIView *)textView swipeLeft:(CGPoint)point
{
}

-(void)endlessTextView:(UIView *)textView swipeRight:(CGPoint)point
{
}

-(void)endlessTextViewTapWithoutSelection:(UIView *)textView
{
}

@end
