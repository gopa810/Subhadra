//
//  InitialDownloadViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 06/01/16.
//
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"

typedef void (^CompletionHandlerType)();

@interface InitialDownloadViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, SSZipArchiveDelegate>


@property IBOutlet UILabel * progressInfo;
@property IBOutlet UILabel * errorInfo;
@property IBOutlet UIButton * restartButton;
@property IBOutlet UIProgressView * progressBar;

@property NSURLSession * downloadSession;
@property (copy) NSString * documentsDirectory;
@property (assign) CompletionHandlerType completionhandler;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong) NSMutableDictionary * completionHandlerDictionary;

-(IBAction)onRestartButton:(id)sender;

- (void) addCompletionHandler: (CompletionHandlerType) handler forSession: (NSString *)identifier;
- (void) callCompletionHandlerForSession: (NSString *)identifier;
- (BOOL) isDownloading;
-(void)cancelDownload;

@end
