//
//  ActiveFolioFileCell.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/29/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "ActiveFolioFileCell.h"
#import "FolioFileDownloaded.h"
#import "VBMainServant.h"
#import "Constants.h"
#import "VBProductManager.h"

@implementation ActiveFolioFileCell

@synthesize tableView;
@synthesize activeFolio, availableFolio;
@synthesize buttons;
@synthesize productIdentifier;
@synthesize cellActionStatus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    cellActionStatus = kCellActionNone;
    progressViewMode = NO;
    [progressView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notification:)
                                                 name:kNotifyPaymentFailed object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notification:)
                                                 name:kNotifyPaymentSucceeded object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

-(void)notification:(NSNotification *)aNotification
{
    NSString * productId;
    SKPaymentTransaction * transaction;

    if ([aNotification.name isEqualToString:kNotifyPaymentFailed])
    {
        transaction = [aNotification.userInfo objectForKey:@"transaction"];
        productId = (transaction.transactionState == SKPaymentTransactionStateRestored) ?transaction.originalTransaction.payment.productIdentifier : transaction.payment.productIdentifier;
        if ([productId isEqualToString:self.productIdentifier])
        {
            self.buttons.enabled = YES;
        }
    }
    else if ([aNotification.name isEqualToString:kNotifyPaymentSucceeded])
    {
        transaction = [aNotification.userInfo objectForKey:@"transaction"];
        productId = (transaction.transactionState == SKPaymentTransactionStateRestored) ?transaction.originalTransaction.payment.productIdentifier : transaction.payment.productIdentifier;
        if ([productId isEqualToString:self.productIdentifier])
        {
            self.buttons.enabled = YES;
            if (cellActionStatus == kCellActionPayStarted)
            {
                [self.tableView reloadData];
                cellActionStatus = 0;
            }
            else if (cellActionStatus == kCellActionBuyStarted)
            {
                [[VBMainServant instance].fileManager startDownloadFile:[self fileName]];
                cellActionStatus = 0;
            }
        }
    }
}

-(NSString *)fileName
{
    if (self.activeFolio)
        return self.activeFolio.fileName;
    if (self.availableFolio)
        return self.availableFolio.fileName;
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)onClickButtonUpdate:(id)sender
{
    VBMainServant * servant = [VBMainServant instance];
    
    NSInteger selected = [self.buttons selectedSegmentIndex];
    if (selected == UISegmentedControlNoSegment)
        return;
    
    [self.buttons setSelectedSegmentIndex:-1];
    NSString * title = [self.buttons titleForSegmentAtIndex:selected];
    
    if ([title hasPrefix:@"Buy"]) {
        cellActionStatus = kCellActionBuyStarted;
        self.buttons.enabled = NO;
        [servant.productManager purchaseProduct:self.availableFolio.product];
        // pay
        // download
        // reload folios
    } else if ([title hasPrefix:@"Pay"]) {
        cellActionStatus = kCellActionPayStarted;
        self.buttons.enabled = NO;
        [servant.productManager purchaseProduct:self.availableFolio.product];
        // only pay
        // reload folios
    } else if ([title isEqualToString:@"Download"]) {
        [servant.fileManager startDownloadFile:[self fileName]];
        //[servant refreshLinksToDownloadedFiles];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyLocalFolioListChanged object:self];
        //[self.tableView reloadData];
    } else if ([title isEqualToString:@"Update"]) {
        [servant.fileManager startDownloadFile:[self fileName]];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyLocalFolioListChanged object:self];
        //[self.tableView reloadData];
    } else if ([title isEqualToString:@"Remove"]) {
        [self startRemove];
    } else if ([title isEqualToString:@"Reconnect"]) {
        [servant.fileManager enumerateFolios];
        [self.tableView reloadData];
    } else if ([title isEqualToString:@"Restore"]) {
        self.buttons.enabled = NO;
        [servant.productManager restorePurchasedItems];
        labelTitle.text = @"Please wait a moment ...";
    }
    
}

-(void)startRemove
{
    NSString * message = [NSString stringWithFormat:@"Remove file %@ from disk", [self fileName]];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm" 
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"Don't remove" 
                                           otherButtonTitles:@"Remove", nil];
    
    [alert show];
}

/*-(void)startDownload
{
    FolioFileDownloaded * down = [[FolioFileDownloaded alloc] init];
    FolioFileBase * file = (self.activeFolio 
                            ? self.activeFolio 
                            : self.availableFolio);
    file.download = down;
    
    [[VBMainServant instance] insertDownloadFile:down];
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:self];
    NSArray * indexesArray = [NSArray arrayWithObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:indexesArray
                          withRowAnimation:UITableViewRowAnimationTop];
    
    // start download
    down.outputFilePath = [[VBMainServant documentsDirectory] stringByAppendingPathComponent:file.fileName];
    down.sourceURL = [[VBMainServant onlineStoreURL] URLByAppendingPathComponent:file.fileName];
    [down setReadMax:file.fileSize];
    [down setCollectionName:file.collectionName];
    [down startDownload];
}*/

-(void)setCellTitle:(NSString *)str
{
    labelTitle.text = str;
}


#pragma mark -
#pragma mark UIAlertView delegate


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.activeFolio && self.activeFolio.filePath && buttonIndex == 1)
    {
        NSFileManager * fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:self.activeFolio.filePath])
        {
            [fm removeItemAtPath:self.activeFolio.filePath
                           error:nil];
            
            NSUserDefaults * userDefs = [NSUserDefaults standardUserDefaults];
            [userDefs setInteger:0 forKey:[NSString stringWithFormat:@"last-update-%@",self.activeFolio.fileName]];

            VBMainServant * inst = [VBMainServant instance];
            NSIndexPath * ip = [self.tableView indexPathForCell:self];
            [inst.fileManager removeActiveFileAtIndex:ip.row];
            //[VBMainServant reloadFiles];
            inst.currentFolio = nil;
            //NSIndexSet * ip = [NSIndexSet indexSetWithIndex:0];
            [inst.fileManager enumerateFolios];
            //[self.tableView reloadData];
        }
    }
}


@end
