//
//  FolioFileDownloaded.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/30/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FolioFileDownloadingDelegate;

@interface FolioFileDownloaded : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection * iStream;
    NSFileHandle * oFile;
    float lastNotification;
    BOOL canceled;
}

@property (nonatomic, retain) id <FolioFileDownloadingDelegate> delegate;
@property (assign, readwrite) float readBytes;
@property (assign, readwrite) float readMax;
@property (assign, readonly) float progress;
@property (assign) NSInteger partsCount;
@property (assign) NSInteger currentPart;
@property (nonatomic, copy) NSString * collectionName;
@property (nonatomic, retain) NSString * outputFilePath;
@property (nonatomic, retain) NSURL * sourceURL;
@property (nonatomic, copy) NSString * sourceFileName;
@property (nonatomic, retain) NSString * temporaryFilePath;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (assign) BOOL supportParts;
@property (assign) BOOL canceled;

-(void)startDownload;
-(void)cancel;
-(void)restart;
-(void)afterDownload;

@end

@protocol FolioFileDownloadingDelegate <NSObject>

-(void)downloadedFile:(FolioFileDownloaded *)file setDownloadProgress:(float)progress;
-(void)downloadedFileDidFinish:(FolioFileDownloaded *)file;
-(void)downloadedFileWillFinish:(FolioFileDownloaded *)file;
-(void)downloadedFile:(FolioFileDownloaded *)file didFailWithError:(NSError *)error;
@end