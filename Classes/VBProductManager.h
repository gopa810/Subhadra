//
//  VBProductManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 27/07/14.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class VBFileManager;

@interface VBProductManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (weak) IBOutlet VBFileManager * fileManager;

@property BOOL productCheckPending;
@property (weak) NSMutableArray * refLocalProducts;
@property (weak) NSMutableArray * refRemoteProducts;
@property SKProductsRequest * productsRequest;

-(void)initializeManager;
-(void)getOnlineAvailableProducts:(NSMutableSet *)productIdentifiers;
-(void)purchaseProduct:(SKProduct *)product;
-(void)restorePurchasedItems;

@end
