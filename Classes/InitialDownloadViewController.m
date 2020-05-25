//
//  InitialDownloadViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 06/01/16.
//
//

#import "InitialDownloadViewController.h"

#import "VBMainServant.h"
#import "ZipArchive.h"

@interface InitialDownloadViewController ()

@end

@implementation InitialDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel * desc = (UILabel *)[self.view viewWithTag:20];
    
    [desc setText:@"I need to download content (full content). Previous versions of Vedabase has been doing this step during update of the main application package. One of the advantages of this approach is quicker update of application."];
    
    
    self.restartButton.hidden = YES;
    
    self.downloadSession = [self backgroundSession];
    self.errorInfo.text = @"";
    [self startDownload];
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

-(IBAction)onRestartButton:(id)sender
{
    [self restartDownload];
}

-(BOOL)isDownloading
{
    return (self.downloadTask != nil);
}

#pragma mark -
#pragma mark Actions

-(void)restartDownload
{
}

-(NSURLSession *)backgroundSession
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.gpsl.vedabase.contentdownload"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

-(void)startDownload
{
    if (self.downloadTask)
        return;
    
    NSURL *downloadURL = [NSURL URLWithString: @"https://s3.amazonaws.com/vedabase-down-uss/vb2016/vedabase.ivd"];

    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.downloadTask = [self.downloadSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
    //self.imageView.hidden = YES;
    //self.progressView.hidden = NO;
    self.progressInfo.text = @"0 (0 %)";
    self.progressBar.progress = 0.0f;
    self.errorInfo.text = @"";
}

-(void)downloadFinished
{
}

-(void)cancelDownload
{
    [self.downloadSession finishTasksAndInvalidate];
    [self.downloadTask cancel];
    self.downloadSession = nil;
    self.downloadTask = nil;
}


-(void)downloadFailed:(NSString *)text
{
    self.errorInfo.text = text;
    self.restartButton.hidden = NO;
}

#pragma mark -
#pragma mark Downloading

- (void) addCompletionHandler: (CompletionHandlerType) handler forSession: (NSString *)identifier
{
    if ([ self.completionHandlerDictionary objectForKey: identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [ self.completionHandlerDictionary setObject:handler forKey: identifier];
}

- (void) callCompletionHandlerForSession: (NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey: identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler.\n");
        
        handler();
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL * documentsDirectory;
    
    if (!self.documentsDirectory)
    {
        NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        documentsDirectory = [URLs objectAtIndex:0];
    }
    else
    {
        documentsDirectory = [NSURL fileURLWithPath:self.documentsDirectory];
    }
    
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
    if (success)
    {
        success = [self addSkipBackupAttributeToItemAtURL:destinationURL];
    }
    
    if ([location isFileURL])
    {
        if ([destinationURL isFileURL])
        {
            NSString * locationPath = [location path];
            NSString * destinationPath = [destinationURL path];
            NSString * locExt = [destinationPath pathExtension];
            
            if ([locExt compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                destinationPath = [[destinationPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"ivd"];
                [SSZipArchive unzipFileAtPath:locationPath
                                toDestination:destinationPath
                                     delegate:self];
            }
            
            NSLog(@"Location: %@\nDestination: %@\n", locationPath, destinationPath);
        }
    }
    
    self.downloadTask = nil;
    
    if (success)
    {
        NSLog(@"Success downloading.");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressInfo.text = @"Done";
            [[VBMainServant instance] performSelectorOnMainThread:@selector(applicationDidFinishedDownloading:)
                                                       withObject:self waitUntilDone:YES];
        });
    }
    else
    {
        /*
         In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
         */
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
        [self performSelectorOnMainThread:@selector(setErrorText:) withObject:[errorCopy localizedDescription] waitUntilDone:YES];
    }
    
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *) URL
{
//    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


-(void)setErrorText:(NSString *)errorText
{
    self.errorInfo.text = errorText;
}

-(void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    /*
     Report progress on the task.
     If you created more than one task, you might keep references to them and report on them individually.
     */
    
    if (downloadTask == self.downloadTask)
    {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressInfo.text = [NSString stringWithFormat:@"%ld KB (%.1f %%)", (long)totalBytesWritten/1024, progress*100.0];
            self.progressBar.progress = (float)progress;
        });
    }
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier)
        [self callCompletionHandlerForSession: session.configuration.identifier];
}



@end
