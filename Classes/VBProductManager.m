//
//  VBProductManager.m
//  VedabaseB
//
//  Created by Peter Kollath on 27/07/14.
//
//

#import "VBProductManager.h"
#import "FolioFileBase.h"
#import "VBFileManager.h"
#import "Constants.h"

@implementation VBProductManager

-(id)init
{
    self = [super init];
    if (self)
    {
        self.refLocalProducts = nil;
        self.refRemoteProducts = nil;
    }
    
    return self;
}


-(void)initializeManager
{
    // payments management
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark -
#pragma mark Purchasing product

-(void)purchaseProduct:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier hasPrefix:@"vedabase"])
    {
        // save the transaction receipt to disk
        ;
        [[NSUserDefaults standardUserDefaults] setValue:[[NSBundle mainBundle] appStoreReceiptURL]
                                                 forKey:transaction.payment.productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId hasPrefix:@"vedabase"])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productId ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    NSLog(@"finishTransaction: received response");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        NSLog(@"finishTransaction: received response - success");
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPaymentSucceeded object:self userInfo:userInfo];
        
        /*NSString * productId = (transaction.transactionState == SKPaymentTransactionStateRestored) ?transaction.originalTransaction.payment.productIdentifier : transaction.payment.productIdentifier;
         if ([productId isEqualToString:self.productIdentifier])
         {
         self.buttons.enabled = YES;
         if (cellActionStatus == kCellActionPayStarted)
         {
         [self.tableView reloadData];
         }
         else if (cellActionStatus == kCellActionBuyStarted)
         {
         [[VBMainServant instance] startDownloadFile:[self fileName]];
         }
         }*/
    }
    else
    {
        NSLog(@"finishTransaction: received response - failed");
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPaymentFailed
                                                            object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    //[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

-(void)restorePurchasedItems
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    BOOL hasRestoring = NO;
    NSLog(@"paymentQueue: received response");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"paymentQueue: complete transaction");
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"paymentQueue: failed transaction");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"paymentQueue: restore transaction");
                [self restoreTransaction:transaction];
                hasRestoring = YES;
                break;
            default:
                break;
        }
    }
    
    if (hasRestoring)
    {
        [self performSelector:@selector(enumerateFolios) withObject:nil afterDelay:1];
    }
}

-(void)getOnlineAvailableProducts:(NSMutableSet *) productIdentifiers
{
    self.productCheckPending = YES;
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    NSLog(@"enumerateFolios: sent prod identifiers for clarification");

}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@" --- productRequest:didReceiveResponse: -------------");
    NSArray * products = response.products;
    
    for (FolioFileBase * file in self.refLocalProducts)
    {
        file.price = nil;
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    for (SKProduct * prod in products)
    {
        FolioFileBase * file = [self.fileManager fileForKey:prod.productIdentifier array:self.refRemoteProducts];
        if (file)
        {
            file.product = prod;
            file.title = [prod localizedTitle];
            if (![userDefaults boolForKey:prod.productIdentifier])
                file.price = [self localizedPriceForProduct:prod];
        }
        else
        {
            file = [self.fileManager fileForKey:prod.productIdentifier array:self.refLocalProducts];
            if (file)
            {
                file.product = prod;
                file.title = [prod localizedTitle];
                file.price = [self localizedPriceForProduct:prod];
            }
        }
        NSLog(@"Title       : %@", prod.localizedTitle);
        NSLog(@"Description : %@", prod.localizedDescription);
        NSLog(@"Price       : %@", prod.price);
        NSLog(@"Product id  : %@", prod.productIdentifier);
    }
    
    for(NSString * invalidProductId in response.invalidProductIdentifiers)
    {
        NSInteger index = [self.fileManager fileIndexForKey:invalidProductId array:self.refRemoteProducts];
        if (index != NSNotFound) {
            [self.refRemoteProducts removeObjectAtIndex:index];
            NSLog(@"Removing product id: %@", invalidProductId);
        }
        NSLog(@"--- Invalid product id: %@", invalidProductId);
    }
    
    //[productsRequest release];
    
    //productCheckPending = NO;
    
    //[self afterValidationOfRemoteFolioList];
}


-(NSString *)localizedPriceForProduct:(SKProduct *)product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    //[numberFormatter release];
    return formattedString;
}




@end
