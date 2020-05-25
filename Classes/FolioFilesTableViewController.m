//
//  FolioFilesTableViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/29/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "FolioFilesTableViewController.h"
#import "VBMainServant.h"

@interface FolioFilesTableViewController ()

@end

@implementation FolioFilesTableViewController


@synthesize loadedActiveCell, loadedDownloadCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        pendingFileItem = [[FolioFileBase alloc] init];
        pendingFileItem.title = @"Loading ...";
        pendingFileItem.isMessage = YES;
        notAvailableFileItem = [[FolioFileBase alloc] init];
        notAvailableFileItem.title = @"Connection not available";
        notAvailableFileItem.isMessage = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notification:)
                                                     name:kNotifyPaymentFailed object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notification:)
                                                     name:kNotifyPaymentSucceeded object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Notifications

-(ActiveFolioFileCell *)findActiveCellForProduct:(NSString *)prodId
{
    int i, m, s;
    UITableViewCell * cell;
    ActiveFolioFileCell * activeCell;
    VBMainServant * servant = [VBMainServant instance];
    for (s = 0; s < 2; s++)
    {
        if (servant.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID)
        {
            m = (s == 0 ? (int)[[servant.fileManager folioFilesActive] count] : (int)[[servant.fileManager folioFilesAvailable] count]);
            for(i = 0; i < m; i++)
            {
                cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:s]];
                if ([cell isKindOfClass:[ActiveFolioFileCell class]])
                {
                    activeCell = (ActiveFolioFileCell *)cell;
                    if ([activeCell.productIdentifier isEqualToString:prodId])
                        return activeCell;
                }
            }
        }
    }
    
    return nil;
}

-(void)notification:(NSNotification *)aNotification
{
    NSString * productId;
    SKPaymentTransaction * transaction;
    ActiveFolioFileCell * cell = nil;
    //NSLog(@"Notification %@ received in cell", aNotification.name);
    
    if ([aNotification.name isEqualToString:kNotifyPaymentFailed])
    {
        transaction = [aNotification.userInfo objectForKey:@"transaction"];
        productId = (transaction.transactionState == SKPaymentTransactionStateRestored) ?transaction.originalTransaction.payment.productIdentifier : transaction.payment.productIdentifier;
        cell = [self findActiveCellForProduct:productId];
        if (cell)
        {
            cell.buttons.enabled = YES;
        }
    }
    else if ([aNotification.name isEqualToString:kNotifyPaymentSucceeded])
    {
        transaction = [aNotification.userInfo objectForKey:@"transaction"];
        productId = (transaction.transactionState == SKPaymentTransactionStateRestored) ?transaction.originalTransaction.payment.productIdentifier : transaction.payment.productIdentifier;
        cell = [self findActiveCellForProduct:productId];
        if (cell)
        {
            cell.buttons.enabled = YES;
            if (cell.cellActionStatus == kCellActionPayStarted)
            {
                [self.tableView reloadData];
            }
            else if (cell.cellActionStatus == kCellActionBuyStarted)
            {
                [[VBMainServant instance].fileManager startDownloadFile:[cell fileName]];
            }
        }
    }
}


#pragma mark - Table view data source

-(NSArray *)currentSectionTitles
{
    if (sectionTitles == nil)
        sectionTitles = [NSArray arrayWithObjects:@"Active Folios", @"Available Folios", @"Transactions", nil];
    return sectionTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;//[self currentSectionTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Installed Files";
    if (section == 2)
        return @"Transactions";
    return @"Available Files";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
    NSInteger length = 0;
    VBMainServant * inst = [VBMainServant instance];

        if (section == 2) {
            return 1;
        }
    if (section == 0) {
        if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID) {
            return [[inst.fileManager folioFilesActive] count];
        } else {
            return 1;
        }
    }
    if (section == 1) {
        //NSLog(@"LISTSTATUS = %d in tableView:numberOfRows...", inst.storageRemoteListStatus);

        if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID) {
            length = [[inst.fileManager folioFilesAvailable] count];
            return (length > 0 ? length: 1);
        } else if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_PENDING) {
            return 1;
        } else if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_UNINIT) {
            [inst.fileManager enumerateFolios];
            return 1;
        } else if (inst.fileManager.remoteFilesError) {
            if (inst.fileManager.lastRemoteListRequestTime < time(NULL) - 60) {
                [inst.fileManager enumerateFolios];
            }
            return 1;
        }
    }
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception in storeTable::numberOfRowsInSection:");
    }
    @finally {
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat smallRow = 41.0;
    CGFloat highRow = 163.0;
    
    @try {
    
        VBMainServant * inst = [VBMainServant instance];
        if (indexPath.section == 0)
        {
            if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID) {
                FolioFileActive * active = [[inst.fileManager folioFilesActive] objectAtIndex:indexPath.row];
                
                if (active.download) {
                    return highRow;
                } else {
                    return smallRow;
                }
            } else {
                return smallRow;
            }
        }
        else if (indexPath.section == 1)
        {
            //NSLog(@"LISTSTATUS = %d in tableView:heightForRow...", inst.storageRemoteListStatus);

            if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID) {
                if ([[inst.fileManager folioFilesAvailable] count] == 0)
                    return smallRow;
                FolioFileBase * ava = [[inst.fileManager folioFilesAvailable] objectAtIndex:indexPath.row];
                return (ava.download ? highRow : smallRow);
            } else {
                return smallRow;
            }
        }
        else if (indexPath.section == 2)
        {
            return smallRow;
        }

    }
    @catch (NSException *exception) {
        //NSLog(@"Exception in heightForRowAtIndexPath:");
    }
    @finally {
    }

    return smallRow;
}

-(void)downloadedFile:(FolioFileDownloaded *)file setDownloadProgress:(float)progress
{
    //NSLog(@"---s-s-s--s");
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:file.indexPath];
    if (cell && [cell isKindOfClass:[DownloadedFileCell class]])
    {
        //NSLog(@"---progress: %f", progress);
        [[(DownloadedFileCell *)cell progressView] setProgress:progress animated:NO];
    }
}

-(void)downloadedFileWillFinish:(FolioFileDownloaded *)file
{
}

-(void)downloadedFileDidFinish:(FolioFileDownloaded *)file
{
    VBMainServant * inst = [VBMainServant instance];

    //VBFolio * folio = inst.currentFolio;
    inst.currentFolio = nil;
    //[folio close];
    [file afterDownload];
    
    [inst.fileManager.folioFilesDownloaded removeObject:file];

    
    [inst.fileManager reenumerateFolios];
    //NSLog(@"downloadingFile: SUCCESS");
    //[inst requestRemoteStorageList];
}

-(void)downloadedFile:(FolioFileDownloaded *)file didFailWithError:(NSError *)error
{
    VBMainServant * inst = [VBMainServant instance];
    
    [inst.fileManager.folioFilesDownloaded removeObjectIdenticalTo:file];
    [inst.fileManager reenumerateFolios];
    //NSLog(@"downloadingFile: ERROR");
    //[inst requestRemoteStorageList];
}

- (id)reusedCell:(NSString *)type tableView:(UITableView *)tableView
{
    if ([type isEqualToString:@"active"])
    {
        ActiveFolioFileCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ActiveFolioFile"];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"ActiveFolioFileCell"
                                          owner:self
                                        options:nil];
            
            cell = self.loadedActiveCell;
            cell.tableView = tableView;
            self.loadedActiveCell = nil;
        }
        return cell;
    }
    else if ([type isEqualToString:@"download"])
    {
        DownloadedFileCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DownCell"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"DownloadedFileCell"
                                          owner:self
                                        options:nil];
            cell = self.loadedDownloadCell;
            cell.progressView.progressTintColor = [VBMainServant colorForName:@"headerBackground"];
            self.loadedDownloadCell = nil;
        }
        return cell;
    }
    
    return nil;
}

-(void)autosizeSegmentedControl:(UISegmentedControl *)control
{
    CGFloat newWidth = 0.0;
    
    for(int i = 0; i < [control numberOfSegments]; i++)
    {
        newWidth += [[control titleForSegmentAtIndex:i] length]*10.0;
        newWidth += 20;
    }

    CGRect bFrame = control.frame;
    control.frame = CGRectMake(bFrame.origin.x + bFrame.size.width - newWidth,bFrame.origin.y,newWidth,bFrame.size.height);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        VBMainServant * inst = [VBMainServant instance];
        UITableViewCell *ret_cell = nil;

        //NSLog(@"Index path = %@", indexPath);
        if (indexPath.section == 0)
        {
            if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID) {
                FolioFileActive * active = [[inst.fileManager folioFilesActive] objectAtIndex:indexPath.row];
                
                if (!active.download) {
                    active.download = [inst.fileManager downloadedFileWithName:active.fileName];
                }

                if (active.download) {
                    DownloadedFileCell * cell = [self reusedCell:@"download" tableView:tableView];
                    cell.titleText.text = active.title;
                    [cell.progressView setProgress:active.download.progress animated:YES];
                    cell.file = active.download;
                    active.download.indexPath = indexPath;
                    active.download.delegate = self;
                    cell.button.selectedSegmentIndex = -1;
                    ret_cell = cell;
                } else {
                    ActiveFolioFileCell * cell = [self reusedCell:@"active" tableView:tableView];
                    [cell setCellTitle: active.title];
                    cell.buttons.hidden = NO;
                    [cell.buttons removeAllSegments];
                    [cell.buttons insertSegmentWithTitle:@"Remove" atIndex:0 animated:NO];
                    if (active.purchased)
                    {
                        if (active.updatePossible)
                        {
                            [cell.buttons insertSegmentWithTitle:@"Update" atIndex:0 animated:NO];
                        }
                    }
                    else
                    {
                        if (active.price && active.product)
                        {
                            NSString * str = nil;
                            if (active.updatePossible)
                            {
                                str = [NSString stringWithFormat:@"Buy %@", active.price];
                            }
                            else
                            {
                                str = [NSString stringWithFormat:@"Pay %@", active.price];
                            }
                            [cell.buttons insertSegmentWithTitle:str atIndex:0 animated:NO];
                            cell.productIdentifier = active.product.productIdentifier;
                        }
                    }
                    cell.activeFolio = active;
                    [self autosizeSegmentedControl:cell.buttons];
                    
                    ret_cell = cell;
                }
            } else {
                ActiveFolioFileCell * cell = [self reusedCell:@"active" tableView:tableView];
                if (inst.fileManager.remoteFilesError) {
                    [cell setCellTitle: @"Connection not available"];
                } else {
                    [cell setCellTitle: @"Loading ..."];
                }
                [cell.buttons removeAllSegments];
                cell.buttons.hidden = YES;
                ret_cell = cell;
            }
        }
        else if (indexPath.section == 1)
        {
            if (inst.fileManager.enumerateFoliosStatus == LISTSTATUS_VALID) {
                
                if ([[inst.fileManager folioFilesAvailable] count] == 0)
                {
                    ActiveFolioFileCell * cell = [self reusedCell:@"active" tableView:tableView];
                    [cell setCellTitle: @"No files"];
                    cell.buttons.hidden = YES;
                    return cell;
                }
                
                FolioFileBase * ava = [[inst.fileManager folioFilesAvailable] objectAtIndex:indexPath.row];

                if (!ava.download) {
                    ava.download = [inst.fileManager downloadedFileWithName:ava.fileName];
                }

                if (ava.download) {
                    DownloadedFileCell * cell = [self reusedCell:@"download" tableView:tableView];
                    cell.titleText.text = ava.title;
                    [cell.progressView setProgress:ava.download.progress animated:YES];
                    cell.file = ava.download;
                    ava.download.indexPath = indexPath;
                    ava.download.delegate = self;
                    cell.button.selectedSegmentIndex = -1;
                    ret_cell = cell;
                } else {
                    ActiveFolioFileCell * cell = [self reusedCell:@"active" tableView:tableView];
                    if (ava) {
                        [cell setCellTitle: ava.title];
                        cell.buttons.hidden = NO;
                        [cell.buttons removeAllSegments];
                        if (!ava.isMessage) {
                            if (ava.price) {
                                if (ava.product) {
                                    NSString * str = [NSString stringWithFormat:@"Buy %@", ava.price];
                                    [cell.buttons insertSegmentWithTitle:str atIndex:0 animated:NO];
                                    cell.productIdentifier = ava.product.productIdentifier;
                                }
                            } else {
                                [cell.buttons insertSegmentWithTitle:@"Download" atIndex:0 animated:NO];
                            }
                        }
                        [self autosizeSegmentedControl:cell.buttons];
                        cell.availableFolio = ava;
                    }
                    ret_cell = cell;
                }
            } else {
                ActiveFolioFileCell * cell = [self reusedCell:@"active" tableView:tableView];
                if (inst.fileManager.remoteFilesError) {
                    [cell setCellTitle: @"Connection not available"];
                    cell.buttons.hidden = NO;
                    [cell.buttons removeAllSegments];
                    [cell.buttons insertSegmentWithTitle:@"Reconnect" atIndex:0 animated:NO];
                    [self autosizeSegmentedControl:cell.buttons];
                } else {
                    [cell setCellTitle: @"Connecting ..."];
                    cell.buttons.hidden = YES;
                }
                ret_cell = cell;
            }
        }
        else if (indexPath.section == 2)
        {
            ActiveFolioFileCell * cell = [self reusedCell:@"active" tableView:tableView];
            [cell setCellTitle: @"Restore purchased items"];
            cell.buttons.hidden = NO;
            [cell.buttons removeAllSegments];
            [cell.buttons insertSegmentWithTitle:@"Restore" atIndex:0 animated:NO];
            [self autosizeSegmentedControl:cell.buttons];
            ret_cell = cell;
        }
        return ret_cell;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
      *detailViewController = [[ alloc] initWithNibName:@"" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


@end
