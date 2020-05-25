//
//  FolioFileDownloaded.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/30/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "FolioFileDownloaded.h"

@implementation FolioFileDownloaded

@synthesize readBytes, readMax;
@synthesize sourceURL, outputFilePath, temporaryFilePath;
@synthesize delegate, indexPath;
@synthesize collectionName;
@synthesize partsCount, currentPart;
@synthesize sourceFileName;
@synthesize supportParts, canceled;

#define kDownPartSize (16*1024*1024)


-(id)init
{
    self = [super init];
    if (self) {
        oFile = nil;
        self.supportParts = NO;
        self.delegate = nil;
    }
    return self;
}

-(float)progress
{
    if (readMax > 1.0)
    {
        return readBytes / readMax;
    }
    
    return 0.0;
}

-(NSURL *)currentUrlAddress
{
    NSString * file;
    if (self.supportParts) {
        file = [NSString stringWithFormat:@"%@.part%03ld", self.sourceFileName, (long)self.currentPart];
    } else {
        file = self.sourceFileName;
    }
    return [self.sourceURL URLByAppendingPathComponent:file];
}

-(void)startDownload
{
    NSFileManager * manager = [NSFileManager defaultManager];
    
    if (self.canceled)
        return;
    
    self.partsCount = ceil(self.readMax / kDownPartSize);
    self.temporaryFilePath = [self.outputFilePath stringByAppendingPathExtension:@"part"];
    if ([manager fileExistsAtPath:self.temporaryFilePath])
    {
        oFile = [NSFileHandle fileHandleForWritingAtPath:self.temporaryFilePath];
        double size = (double)[oFile seekToEndOfFile];
        self.currentPart = floor(size / kDownPartSize);
        lastNotification = (float)(self.currentPart * kDownPartSize);
        self.readBytes = lastNotification;
        [oFile truncateFileAtOffset:self.currentPart * kDownPartSize];
        //NSLog(@"Found existing file %@ of size:: %f", self.temporaryFilePath, lastNotification);
    }
    else {
        if (self.canceled == NO)
        {
            [manager createFileAtPath:self.temporaryFilePath
                             contents:[NSData data]
                           attributes:nil];
            NSError * error = nil;
            NSURL * URL = [NSURL fileURLWithPath:self.temporaryFilePath];
            BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                          forKey:NSURLIsExcludedFromBackupKey
                                           error:&error];
            if (!success) {
                //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
            }
        }
        else {
            return;
        }
        self.currentPart = 0;
        //NSLog(@"Creating new file for downloading: %@", self.temporaryFilePath);
    }
    //NSLog(@"Opening file: %@", [self currentUrlAddress]);
    NSURLRequest * request = [NSURLRequest requestWithURL:[self currentUrlAddress]];
    iStream = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[NSURLConnection connectionWithRequest:request delegate:self];
 /*   iStream = [[NSInputStream alloc] initWithURL:self.sourceURL];
    
    [iStream setDelegate:self];
    [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [iStream open];
 */   
}

-(void)afterDownload
{
    NSFileManager * manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:self.outputFilePath])
    {
        [manager removeItemAtPath:self.outputFilePath error:nil];
    }
    
    [manager moveItemAtPath:self.temporaryFilePath
                     toPath:self.outputFilePath error:nil];
    
    NSError * error = nil;
    NSURL * URL = [NSURL fileURLWithPath:self.outputFilePath];
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if (!success) {
        //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }

}

-(void)cancel
{
    //NSLog(@"- stream is canceled");
    self.canceled = YES;
    [iStream cancel];
    [oFile closeFile];
    [[NSFileManager defaultManager] removeItemAtPath:self.temporaryFilePath error:NULL];
    //NSLog(@"File removed : %d", removed);
    [delegate downloadedFile:self didFailWithError:nil];
}

-(void)restart
{
    //NSLog(@"- stream is restarted");
    [iStream cancel];
    iStream = nil;
    [oFile closeFile];
    oFile = nil;
    //[delegate downloadedFile:self didFailWithError:nil];
    [self performSelector:@selector(startDownload)
               withObject:nil
               afterDelay:1.0];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[delegate downloadedFile:self didFailWithError:error];
    //[iStream release];
    iStream = nil;
    [oFile closeFile];
    oFile = nil;
    
    //NSLog(@"=== connection failed, trying to restart it ===");
    [self performSelector:@selector(startDownload)
               withObject:nil
               afterDelay:1.0];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.supportParts)
    {
        //[iStream release];
        iStream = nil;
        self.currentPart++;
        if (self.currentPart < self.partsCount)
        {
            NSURL * url = [self currentUrlAddress];
            NSURLRequest * request = [NSURLRequest requestWithURL:url];
            iStream = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
        else
        {
            [oFile closeFile];
            [delegate downloadedFileDidFinish:self];
        }
    }
    else
    {
        [oFile closeFile];
        [delegate downloadedFileDidFinish:self];
        //[iStream release];
        iStream = nil;
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (oFile == nil)
    {
        oFile = [NSFileHandle fileHandleForWritingAtPath:self.temporaryFilePath];
        lastNotification = 0.0;
    }
    [oFile writeData:data];
    readBytes += [data length];

    @try {
        if (readBytes - lastNotification > 1048000)
        {
            //NSLog(@"File Downloading, current size = %f", self.readBytes);
            [delegate downloadedFile:self setDownloadProgress:self.progress];
            lastNotification = readBytes;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

@end
