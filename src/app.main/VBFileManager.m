//
//  VBFileManager.m
//  VedabaseB
//

//  Created by Peter Kollath on 26/07/14.
//
//

#import "VBFileManager.h"
#import "Constants.h"
#import "VBFolioStorage.h"
#import "VBMainServant.h"
#import "VBProductManager.h"

@implementation VBFileManager

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        self.folioDocuments = [[NSMutableArray alloc] init];
        self.folioList = [[NSMutableArray alloc] init];
        self.enumerateFoliosStatus = LISTSTATUS_UNINIT;
        self.folioListStatus = LISTSTATUS_UNINIT;
        self.enumerateFoliosDone = NO;
        self.enumerateFoliosPending = NO;
        self.availableFoliosLock = [[NSLock alloc] init];
        self.enumerateFoliosLock = [[NSLock alloc] init];
        self.availableFoliosRequestSender = nil;
        //self.lastRemoteListRequestTime = 0;
        self.dowloadListLock = [[NSLock alloc] init];
        self.updateFiles = [[NSMutableArray alloc] init];

    }
    
    return self;
}

-(NSData *)mainTextJavaScript
{
    if (self.mainJavaScript == nil)
    {
        NSString * mainTextJavaScriptPath = [[NSBundle mainBundle] pathForResource:@"maintext" ofType:@"txt"];
        self.mainJavaScript = [[NSData alloc] initWithContentsOfFile:mainTextJavaScriptPath];
    }
    return self.mainJavaScript;
}

-(void)setCollectionAndFileList:(NSDictionary *)userInfo
{
    NSMutableArray * localFiles = [userInfo valueForKey:@"localFiles"];
    NSMutableArray * remoteFiles = [userInfo valueForKey:@"remoteFiles"];
    NSMutableArray * folios = [userInfo valueForKey:@"collections"];
    
    self.folioFilesActive = localFiles;
    self.folioFilesAvailable = remoteFiles;
    self.folioList = folios;
    
    self.enumerateFoliosStatus = LISTSTATUS_VALID;
}

-(FolioFileBase *)remoteFileForKey:(NSString *)aKey
{
    for (FolioFileBase * file in self.folioFilesAvailable)
    {
        if ([file.key isEqualToString:aKey])
        {
            return file;
        }
    }
    return nil;
}

-(FolioFileBase *)remoteFileWithName:(NSString *)aName
{
    for (NSInteger index = 0; index < [self.folioFilesAvailable count]; index++)
    {
        FolioFileBase * file = [self.folioFilesAvailable objectAtIndex:index];
        if ([file.fileName isEqualToString:aName])
        {
            return file;
        }
    }
    return nil;
}


-(NSInteger)remoteFileIndexForKey:(NSString *)aKey
{
    NSInteger found = NSNotFound;
    for (NSInteger index = 0; index < [self.folioFilesAvailable count]; index++)
    {
        FolioFileBase * file = [self.folioFilesAvailable objectAtIndex:index];
        if ([file.key isEqualToString:aKey])
        {
            found = index;
            break;
        }
    }
    return found;
}

-(NSInteger)findFolioFileIndex:(NSString *)fileName inArray:(NSArray *)array
{
    for (NSInteger index = 0; index < [array count]; index++)
    {
        FolioFileBase * file = (FolioFileBase *)[array objectAtIndex:index];
        //NSLog(@"Compare: %@ <-> %@", file.fileName, fileName);
        if ([file.fileName isEqualToString:fileName])
            return index;
    }
    
    return NSNotFound;
}

-(NSInteger)fileIndexForKey:(NSString *)aKey array:(NSArray *)array
{
    NSInteger found = NSNotFound;
    for (NSInteger index = 0; index < [array count]; index++)
    {
        FolioFileBase * file = [array objectAtIndex:index];
        if ([file.key isEqualToString:aKey])
        {
            found = index;
            break;
        }
    }
    return found;
}

-(NSInteger)findLocalFolioFileIndex:(NSString *)fileName
{
    return [self findFolioFileIndex:fileName inArray:self.folioFilesActive];
}

-(FolioFileBase *)fileForKey:(NSString *)aKey array:(NSArray *)array
{
    for (NSInteger index = 0; index < [array count]; index++)
    {
        FolioFileBase * file = [array objectAtIndex:index];
        if ([file.key isEqualToString:aKey])
        {
            return file;
        }
    }
    return nil;
}

-(FolioFileActive *)localFileForKey:(NSString *)aKey
{
    for (NSInteger index = 0; index < [self.folioFilesActive count]; index++)
    {
        FolioFileActive * file = [self.folioFilesActive objectAtIndex:index];
        if ([file.key isEqualToString:aKey])
        {
            return file;
        }
    }
    return nil;
}

-(FolioFileActive *)localFileWithName:(NSString *)aName
{
    for (NSInteger index = 0; index < [self.folioFilesActive count]; index++)
    {
        FolioFileActive * file = [self.folioFilesActive objectAtIndex:index];
        if ([file.fileName isEqualToString:aName])
        {
            return file;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark folio list operations
// these operations are executed only on main thread
// and they are called from background threads
// to prevent synchronization colisions

-(void)removeActiveFileAtIndex:(NSInteger)index
{
    [self.folioFilesActive removeObjectAtIndex:index];
    self.folioFilesAvailable = nil;
    self.lastRemoteListRequestTime = 0;
}

#pragma mark -

#pragma mark -
#pragma mark list of local storage files



-(void)insertStorageDictionary:(FolioFileActive *)sd intoArray:(NSMutableArray *)arr
{
    BOOL inserted = NO;
    for(int i = 0; i < [arr count]; i++)
    {
        FolioFileActive * dict = (FolioFileActive *)[arr objectAtIndex:i];
        if ([dict.sortKey compare:sd.sortKey] == NSOrderedDescending)
        {
            [arr insertObject:sd atIndex:i];
            inserted = YES;
            break;
        }
    }
    
    if (!inserted)
    {
        [arr addObject:sd];
    }
}

-(void)retrieveLastValueForKey:(NSString *)key
                      selector:(SEL)selector
                    dictionary:(NSMutableDictionary *)dict
{
    NSArray * arr = [dict objectForKey:@"storages"];
    for (NSInteger i = [arr count] - 1; i >= 0; i--)
    {
        NSDictionary * item = (NSDictionary *)[arr objectAtIndex:i];
        if ([item respondsToSelector:selector])
        {
            [dict setValue:[item performSelector:selector] forKey:key];
            break;
        }
    }
}


-(void)scanFoliosDirectory:(NSString *)startDir extension:(NSString *)extStr
                     array:(NSMutableArray *)tmpFolios writeable:(BOOL)writeable
{
	NSFileManager * fm = [NSFileManager defaultManager];
	NSError * error = nil;
    NSString * path = nil;
    NSInteger index;
	NSArray * cont = [fm contentsOfDirectoryAtPath:startDir error:&error];
    NSMutableArray * candidates = [[NSMutableArray alloc] init];
    
    for (NSString * strFile in cont)
    {
        if ([strFile hasSuffix:extStr])
        {
            path = [startDir stringByAppendingPathComponent:strFile];
            FolioFileActive * active = [[FolioFileActive alloc] initWithFilePath:path];
            //NSLog(@"Found storage package at path: %@", path);
            [tmpFolios addObject:active];
        }
    }
    
    return;
    
    // if we are in writeable location, then we have to be sure, that
    // all files from not-writeable location have copy here
    if (writeable)
    {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL forceCopy = NO;
        NSString * localVersion = [userDefaults valueForKey:kLocalStoreFilesVersionProperty];
        if (localVersion == nil || [localVersion isEqualToString:self.mainServant.buildDate] == NO)
        {
            forceCopy = YES;
            [userDefaults setValue:self.mainServant.buildDate
                            forKey:kLocalStoreFilesVersionProperty];
        }
        for (FolioFileActive * tmp1 in tmpFolios)
        {
            if (([candidates indexOfObject:tmp1.fileName] == NSNotFound) || forceCopy)
            {
                path = [startDir stringByAppendingPathComponent:tmp1.fileName];
                [fm copyItemAtPath:tmp1.filePath toPath:path error:NULL];
                [candidates addObject:tmp1.fileName];
                
                // set flag NO_BACKUP to newly copied item
                NSError * error = nil;
                NSURL * URL = [NSURL fileURLWithPath:path];
                BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                              forKey:NSURLIsExcludedFromBackupKey
                                               error:&error];
                if (!success) {
                    NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
                }
            }
        }
    }
    
    for (NSString * strFile in candidates)
    {
        index = [self findFolioFileIndex:strFile inArray:tmpFolios];
        if (index != NSNotFound) {
            [tmpFolios removeObjectAtIndex:index];
        }
        path = [startDir stringByAppendingPathComponent:strFile];
        FolioFileActive * active = [[FolioFileActive alloc] initWithFilePath:path];
        //NSLog(@"Found storage package at path: %@", path);
        // needs to be purchased?
        active.purchased = YES;
        if ([active.key length] > 0) {
            // is purchased?
            active.purchased = [[NSUserDefaults standardUserDefaults] boolForKey:active.key];
        }
        [tmpFolios addObject:active];
        active = nil;
        //[active release];
    }
    
    candidates = nil;//[candidates release];
}

-(NSString *)documentsDirectory
{
    NSString * g_docDir;
    
#if (TARGET_IPHONE_SIMULATOR)
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSLog(@"Document sdirectory is: =====================\n%@\n", [paths objectAtIndex:0]);
        g_docDir = @"/Users/Shared/Work";
#else
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        g_docDir = [paths objectAtIndex:0];
#endif
    
    
    return g_docDir;
}

-(void)localStorageList:(NSMutableArray *)tmpFolios
{
    NSString * startDir;
    
    // first look into own resources
    //startDir = [[NSBundle mainBundle] resourcePath];
    startDir = [self documentsDirectory];
    [self scanFoliosDirectory:startDir extension:@"2015.ivd" array:tmpFolios writeable:NO];
    
 
}

-(BOOL)reenumerateFolios
{
    if (self.enumerateFoliosPending)
        return NO;
    
    [self performSelectorInBackground:@selector(enumerateFoliosBackgroundTask:) withObject:self];
    return NO;
}

// returns YES, if there is at least one folio documents
-(BOOL)enumerateFolios
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSString * path = [NSBundle.mainBundle pathForResource:@"folio" ofType:@"db"];
    
    if ([fm fileExistsAtPath:path]) {
        [self.folioDocuments addObject:path];
        NSLog(@"Folio file found");
    } else {
        NSLog(@"Folio DOES NOT FOUND");
    }
    
    return (self.folioDocuments.count > 0);
    
    
    NSError * error = nil;
    NSString * documentsDirectory = [self documentsDirectory];
    NSArray * cont = [fm contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    [self.folioDocuments removeAllObjects];
    for (NSString * strFile in cont)
    {
        if ([strFile hasSuffix:@".db"])
        {
            path = [documentsDirectory stringByAppendingPathComponent:strFile];
            //NSLog(@"Found storage package at path: %@", path);
            if ([strFile isEqualToString:@"folio.db"]) {
                [self.folioDocuments addObject:path];
            } else {
                [fm removeItemAtPath:path error:&error];
            }
        }
    }

    // set file lists
/*    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.folioDocuments, @"localFiles", nil];
    NSNotification * note = [NSNotification notificationWithName:kNotifyCollectionsListChanged
                                                          object:self userInfo:userInfo];
    [self.mainServant performSelectorOnMainThread:@selector(sendNotification:)
                                       withObject:note waitUntilDone:YES];
*/
    return (self.folioDocuments.count > 0);
}

//
// main task for retrieving all files and information related to folios
//
-(void)enumerateFoliosBackgroundTask:(id)sender
{
    [self.enumerateFoliosLock lock];
    self.enumerateFoliosPending = YES;
    self.enumerateFoliosStatus = LISTSTATUS_PENDING;
    self.remoteFilesError = NO;
    
    @try {
        NSInteger timeoutCheckProducts = 0;
        NSMutableArray * folios = [[NSMutableArray alloc] init];
        NSMutableArray * tmpFolios = [[NSMutableArray alloc] init];
        NSMutableArray * remoteFolios = [[NSMutableArray alloc] init];
        NSMutableSet * productIdentifiers = [[NSMutableSet alloc] initWithCapacity:10];
        
        //NSLog(@"enumerateFolios: reading local files");
        // get local files
        [self localStorageList:folios];
        
        //NSLog(@"enumerateFolios: extracting collections");
        // extract collections
        [self extractCollections:tmpFolios fromLocalFiles:folios];
        
        if (false)//([[NSUserDefaults standardUserDefaults] boolForKey:kASStoreAvailable])
        {
            //NSLog(@"enumerateFolios: reading remote files");
            // get remote files
            [self remoteStorageList:remoteFolios];
            
            if ([remoteFolios count] == 0)
            {
                FolioFileBase * file = [[FolioFileBase alloc] init];
                file.title = @"No new files!";
                file.isMessage = YES;
                [remoteFolios addObject:file];
                //[file release];
            }
            else
            {
                // remove files from list of remote files, which are already downloaded and are local
                [self removeRemoteFiles:remoteFolios presentInLocal:folios];
            }
            
            
            //NSLog(@"enumerateFolios: extracting product identifiers");
            [self extractProductIdentifiers:productIdentifiers localFiles:folios remoteFiles:remoteFolios];
            
            self.productManager.productCheckPending  = NO;
            if ([productIdentifiers count] > 0)
            {
                self.productManager.refLocalProducts = folios;
                self.productManager.refRemoteProducts = remoteFolios;

                [self.productManager getOnlineAvailableProducts:productIdentifiers];
            }
            
            timeoutCheckProducts = 0;
            while (self.productManager.productCheckPending && timeoutCheckProducts < 30)
            {
                //NSLog(@"enumerateFolios: putting to sleep due to wait for product checking %ld", (long)timeoutCheckProducts);
                [NSThread sleepForTimeInterval:1];
                timeoutCheckProducts++;
            }
            
            if (timeoutCheckProducts == 30)
            {
                //NSLog(@"ERROR: check products has run out of time");
                self.remoteFilesError = YES;
            }
        }
        
        
        // set file lists
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:folios, @"localFiles", remoteFolios, @"remoteFiles", tmpFolios, @"collections", nil];
        
        
        //NSLog(@"enumerateFolios: setting list of files to object variables");
        [self performSelectorOnMainThread:@selector(setCollectionAndFileList:) withObject:userInfo waitUntilDone:YES];
        self.enumerateFoliosStatus = LISTSTATUS_VALID;
        
        // send notification
        //NSLog(@"enumerateFolios: sending notification about finishing enumerateFolios");
        NSNotification * note = [NSNotification notificationWithName:kNotifyCollectionsListChanged
                                                              object:self
                                                            userInfo:userInfo];
        [self.mainServant performSelectorOnMainThread:@selector(sendNotification:)
                               withObject:note
                            waitUntilDone:YES];
        
        
        folios = nil;//[folios release];
        tmpFolios = nil;//[tmpFolios release];
        remoteFolios = nil;//[remoteFolios release];
        productIdentifiers = nil;//[productIdentifiers release];
        
        //NSLog(@"enumerateFolios: setting indicators of execution");
        self.enumerateFoliosDone = YES;
        self.enumerateFoliosPending = NO;
    }
    @catch (NSException *exception) {
        //NSLog(@"ERROR: enumerateFolios: Exception: %@", [exception description]);
    }
    @finally {
    }
    
    [self.enumerateFoliosLock unlock];
    
}

-(void)extractCollections:(NSMutableArray *)tmpFolios fromLocalFiles:(NSArray *)folios
{
	NSMutableDictionary * collectionDict = nil;
    NSMutableSet * includeFiles = [[NSMutableSet alloc] init];
    
    for (FolioFileActive * active in folios)
    {
        [includeFiles addObjectsFromArray:active.includeFiles];
    }
    
	for (FolioFileActive * active in folios)
	{
        collectionDict = [[NSMutableDictionary alloc] init];
        //[collectionDict addEntriesFromDictionary:dict];
        [collectionDict setObject:active.collection forKey:@"Collection"];
        NSMutableArray * storages = [[NSMutableArray alloc] initWithObjects:active, nil];
        [collectionDict setObject:storages forKey:@"storages"];
        //[storages release];
        [tmpFolios addObject:collectionDict];
        //[collectionDict release];
    }
    
    for (NSMutableDictionary * itemDict in tmpFolios)
    {
        [self retrieveLastValueForKey:@"Image" selector:@selector(image) dictionary:itemDict];
        [self retrieveLastValueForKey:@"DATE" selector:@selector(date) dictionary:itemDict];
        [self retrieveLastValueForKey:@"AS" selector:@selector(abstract) dictionary:itemDict];
        [self retrieveLastValueForKey:@"CollectionName" selector:@selector(collectionName) dictionary:itemDict];
    }
    
    //[includeFiles release];
}

-(void)extractProductIdentifiers:(NSMutableSet *)productIdentifiers
                      localFiles:(NSArray *)localFiles
                     remoteFiles:(NSArray *)remoteFiles
{
    for (FolioFileBase * remoteFile in remoteFiles)
    {
        if (remoteFile.key && [remoteFile.key length] > 0)
        {
            [productIdentifiers addObject:remoteFile.key];
            //NSLog(@"extractProductIdentifiers: prod id added: %@", remoteFile.key);
        }
    }
    for (FolioFileActive * localFile in localFiles)
    {
        if (!localFile.purchased)
        {
            [productIdentifiers addObject:localFile.key];
            //NSLog(@"extractProductIdentifiers: prod id added: %@", localFile.key);
        }
    }
}

#pragma mark -
#pragma mark Downloading files

-(NSArray *)downloadedFiles
{
    if (self.folioFilesDownloaded == nil) {
        //NSMutableArray * array = ;
        self.folioFilesDownloaded = [[NSMutableArray alloc] init];
        //[array release];
    }
    
    return self.folioFilesDownloaded;
}

//
// function checks if some files are downloaded
// if not, will try to find files, whose downloading process
// was not finished
//
-(void)resumeDownloading
{
    if (self.folioFilesDownloaded != nil)
        return;
    
    self.folioFilesDownloaded = [[NSMutableArray alloc] init];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    //NSLog(@"==-getting content of documents");
    NSArray * files = [manager contentsOfDirectoryAtPath:[self documentsDirectory] error:NULL];
    
    if (files)
    {
        for(NSString * fileName in files)
        {
            //NSLog(@"-found file %@", fileName);
            if ([fileName hasSuffix:@".part"])
            {
                //NSLog(@" -starting download: %@", fileName);
                [self startDownloadFile:[fileName substringToIndex:([fileName length] - 5)]];
            }
        }
    }
    
}

-(void)insertDownloadFile:(FolioFileDownloaded *)fileDown
{
    [self.dowloadListLock lock];
    [self.folioFilesDownloaded addObject:fileDown];
    [self.dowloadListLock unlock];
}

-(FolioFileDownloaded *)downloadedFileWithName:(NSString *)aName
{
    for (NSInteger index = 0; index < [self.folioFilesDownloaded count]; index++)
    {
        FolioFileDownloaded * file = [self.folioFilesDownloaded objectAtIndex:index];
        if ([file.sourceFileName isEqualToString:aName])
        {
            return file;
        }
    }
    return nil;
}

-(void)refreshLinksToDownloadedFiles
{
    if (self.folioFilesActive)
    {
        for(FolioFileBase * file in self.folioFilesActive)
        {
            file.download = nil;
        }
    }
    
    if (self.folioFilesAvailable)
    {
        for(FolioFileBase * file in self.folioFilesAvailable)
        {
            file.download = nil;
        }
    }
    
    // refresh links to downloaded files
    FolioFileBase * file;
    if (self.folioFilesDownloaded)
    {
        for(FolioFileDownloaded * down in self.folioFilesDownloaded)
        {
            // looks for file in list of local/remote files
            file = [self anyFileWithName:down.sourceFileName];
            
            // if file was found, assign downloading agent
            if (file) {
                file.download = down;
            }
        }
    }
    
}


-(FolioFileBase *)anyFileWithName:(NSString *)strFile
{
    FolioFileBase * file = [self localFileWithName:strFile];
    
    // if not local, then looks for file
    // in the list of remote files
    if (file == nil) {
        file = [self remoteFileWithName:strFile];
    }
    
    return file;
}


//
// starts downloading of fileName (only name of file)
// path is appended according local or remote location
//
-(void)startDownloadFile:(NSString *)fileName
{
    // creates download agent
    //
    FolioFileDownloaded * down = [[FolioFileDownloaded alloc] init];
    FolioFileBase * file;
    
    // looks for file in list of local files
    file = [self anyFileWithName:fileName];
    
    // if file was found, assign downloading agent
    if (file)
    {
        file.download = down;
        [self insertDownloadFile:down];
        
        // start download
        down.outputFilePath = [[self documentsDirectory] stringByAppendingPathComponent:file.fileName];
        down.sourceURL = [self onlineStoreURL];
        down.sourceFileName = file.fileName;
        down.supportParts = file.supportParts;
        [down setReadMax:file.fileSize];
        [down setCollectionName:file.collectionName];
        //NSLog(@"=> start download from MainServant::startDownloadFile");
        [down startDownload];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyLocalFolioListChanged object:self];
}

-(NSURL *)onlineStoreURL
{
#if (TARGET_IPHONE_SIMULATOR)
    return [NSURL fileURLWithPath:@"/Library/Application Support/iPadFolio5"];
#else
    return [NSURL URLWithString:@"http://gopal.home.sk/data"];
#endif
}

#pragma mark -
#pragma mark list of remote storage files

-(void)logArray:(NSArray *)array withTitle:(NSString *)title
{
    //NSLog(@"==================================");
    //NSLog(@"Title: %@", title);
    //NSLog(@"==================================");
    
    //for(FolioFileBase * base in array)
    //{
        //NSLog(@"   %@", base.fileName);
    //}
    
    //NSLog(@"==================================");
}

-(void)removeRemoteFiles:(NSMutableArray *)array presentInLocal:(NSArray *)localArray
{
    FolioFileBase * ava;
    //NSLog(@"before merging local and remote file list");
    [self logArray:self.folioFilesActive withTitle:@"Active"];
    [self logArray:array withTitle:@"Available"];
    
    NSInteger index = 0;
    NSInteger foundIndex = -1;
    while(index < [array count])
    {
        ava = (FolioFileBase *)[array objectAtIndex:index];
        foundIndex = -1;
        for (FolioFileActive * active in localArray)
        {
            //NSLog(@"Compare Remote: %@  <-> %@", ava.fileName, active.fileName);
            if ([ava.fileName isEqualToString:active.fileName])
            {
                if (ava.tbuild > active.tbuild)
                {
                    active.updatePossible = YES;
                }
                active.fileSize = ava.fileSize;
                active.supportParts = ava.supportParts;
                active.lastUpdate = ava.lastUpdate;
                foundIndex = 1;
                break;
            }
        }
        if (foundIndex >= 0) {
            [array removeObjectAtIndex:index];
        }
        else {
            index++;
        }
    }
    
    //NSLog(@"after merging local and remote file list");
    [self logArray:self.folioFilesActive withTitle:@"Active"];
    [self logArray:array withTitle:@"Available"];
}

-(void)remoteStorageList:(NSMutableArray *)array
{
    NSError * error = nil;
    NSURL * url = [[self onlineStoreURL] URLByAppendingPathComponent:@"available.txt"];
    NSString * string = [NSString stringWithContentsOfURL:url
                                                 encoding:NSASCIIStringEncoding
                                                    error:&error];
    
    self.lastRemoteListRequestTime = time(NULL);
    if (string == nil && error != nil)
    {
        self.remoteFilesError = YES;
        return;
    }
    
    NSArray * lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    FolioFileBase * ava = nil;
    
    for (NSString * line in lines)
    {
        if ([line hasPrefix:@"FILE="]) {
            ava = [[FolioFileBase alloc] init];
            [array addObject:ava];
            //[ava release];
            ava.fileName = [line substringFromIndex:5];
        } else if ([line hasPrefix:@"TT="]) {
            if (ava) {
                ava.title = [line substringFromIndex:3];
            }
        } else if ([line hasPrefix:@"SIZE="]) {
            if (ava) {
                ava.fileSize = [[line substringFromIndex:5] integerValue];
            }
        } else if ([line hasPrefix:@"TBUILD="]) {
            if (ava) {
                NSString * part = [line substringFromIndex:7];
                NSInteger intPart = [part integerValue];
                ava.tbuild = intPart;
            }
        } else if ([line hasPrefix:@"CNAME="]) {
            if (ava) {
                ava.collectionName = [line substringFromIndex:6];
            }
        } else if ([line hasPrefix:@"INCLUDES="]) {
            if (ava) {
                [ava.includeFiles addObject:[line substringFromIndex:9]];
            }
        } else if ([line hasPrefix:@"KEY="]) {
            if (ava) {
                ava.key = [line substringFromIndex:4];
            }
        } else if ([line hasPrefix:@"PARTS="]) {
            if (ava) {
                ava.supportParts = [line isEqualToString:@"PARTS=YES"];
            }
        } else if ([line hasPrefix:@"LASTUPDATE="]) {
            if (ava) {
                NSString * part = [line substringFromIndex:11];
                ava.lastUpdate = [part integerValue];
                NSLog(@"last update is %ld", (long)ava.lastUpdate);
            }
        }
    }
}

-(void)checkInlineUpdatesForFile
{
    if ([[VBMainServant instance] currentFolio] == nil)
    {
        //NSLog(@"checkInlineUpdate refused due to currentFolio == nil");
        return;
    }
    
    if (self.enumerateFoliosStatus != LISTSTATUS_VALID)
    {
        //NSLog(@"checkInlineUpdate refused due to remoteList == nil");
        return;
    }
    
    if ([self.updateFiles count] > 0)
    {
        //NSLog(@"checkInlineUpdate refused dues to already updating");
        return;
    }
    
    //NSLog(@"checkInlineUpdate - trying to check");
    
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    VBFolioStorage * file = self.mainServant.currentFolio.firstStorage;
    NSInteger lastUpdateLocal = 0;
    FolioFileBase * ff = [self anyFileWithName:file.fileName];
    if (ff)
    {
        lastUpdateLocal = [defs integerForKey:[NSString stringWithFormat:@"last-update-%@", file.fileName]];
    }
    //NSLog(@"lastUpdateLocal = %ld, lastUpdateRemote = %ld", (long)lastUpdateLocal, (long)ff.lastUpdate);
    while ((lastUpdateLocal == 0 || lastUpdateLocal < ff.lastUpdate) && ff.lastUpdate > 0)
    {
        NSString * newFile = [NSString stringWithFormat:@"%@-updates-%d.sql", [file.fileName stringByDeletingPathExtension], (int)lastUpdateLocal+1];
        NSDictionary * cmd = [NSDictionary dictionaryWithObjectsAndKeys:newFile, @"newFile",
                              file.fileName, @"originalFile", [NSNumber numberWithInteger:(lastUpdateLocal+1)], @"update", nil];
        [self.updateFiles addObject:cmd];
        //NSLog(@"- added file for download: %@", newFile);
        lastUpdateLocal++;
    }
    
    [self startDownloadingInlineUpdates];
}

-(void)startDownloadingInlineUpdates
{
    if ([self.updateFiles count] > 0)
    {
        [self performSelectorInBackground:@selector(downloadInlineUpdateFile:) withObject:[self.updateFiles objectAtIndex:0]];
    }
}

-(void)downloadInlineUpdateFile:(NSDictionary *)fileRec
{
    NSString * file = [fileRec objectForKey:@"newFile"];
    NSDictionary * object = nil;
    NSError * error = nil;
    NSURL * url = [[self onlineStoreURL] URLByAppendingPathComponent:file];
    NSString * string = [NSString stringWithContentsOfURL:url
                                                 encoding:NSASCIIStringEncoding
                                                    error:&error];
    
    //NSLog(@"trying to download file: %@", url);
    
    self.lastRemoteListRequestTime = time(NULL);
    if (string == nil && error != nil)
    {
        object = [NSDictionary dictionaryWithObjectsAndKeys:file, @"file", fileRec, @"rec", nil];
        //NSLog(@"--> downloaded FAIL");
    }
    else
    {
        if ([string hasPrefix:@"[SCRIPT]"])
        {
            NSArray * lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            object = [self compileUpdateScript:lines file:file fileRec:fileRec];
        }
        else
        {
            // this is sql file, just run it
            object = [NSDictionary dictionaryWithObjectsAndKeys:file, @"file", string, @"content", fileRec, @"rec", nil];
            //NSLog(@"--> downloaded OK");
        }
    }
    [self performSelectorOnMainThread:@selector(processInlineUpdateFile:)
                           withObject:object
                        waitUntilDone:NO];
}

-(NSDictionary *)compileUpdateScript:(NSArray *)lines file:(NSString *)file fileRec:(NSDictionary *)fileRec
{
    NSMutableArray * commands = [[NSMutableArray alloc] init];
    NSMutableArray * stack = [[NSMutableArray alloc] init];
    for (NSString * line in lines)
    {
        if ([line isEqualToString:@"Clear"]) {
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"BindString"]) {
            if ([stack count] == 2) {
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:[stack objectAtIndex:0], @"String",
                                     [stack objectAtIndex:1], @"BindIndex", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"BindInteger"]) {
            if ([stack count] == 2) {
                NSNumber * number = [NSNumber numberWithInteger:[[stack objectAtIndex:0] integerValue]];
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:number, @"Integer", [stack objectAtIndex:1], @"BindIndex", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"BindBlob"]) {
            if ([stack count] == 2) {
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[stack objectAtIndex:0]]];
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:data, @"Blob", [stack objectAtIndex:1], @"BindIndex", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"SqlQueryDefine"]) {
            if ([stack count] > 0) {
                NSString * query = [stack componentsJoinedByString:@"\n"];
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:query, @"Query", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"SqlQueryExecute"]) {
            [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:line, @"command", nil]];
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"NewFile"]) {
            if ([stack count] == 2) {
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[stack objectAtIndex:0]]];
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:data, @"Data", [stack objectAtIndex:1], @"FileName", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"SetStringAppProperty"]) {
            if ([stack count] == 2) {
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:[stack objectAtIndex:0], @"Name", [stack objectAtIndex:1], @"Value", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"SetNumberAppProperty"]) {
            if ([stack count] == 2) {
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:[stack objectAtIndex:0], @"Name", [NSNumber numberWithInteger:[[stack objectAtIndex:1] integerValue]], @"Value", line, @"command", nil]];
            }
            [stack removeAllObjects];
        } else if ([line isEqualToString:@"SetBoolAppProperty"]) {
            if ([stack count] == 2) {
                [commands addObject:[NSDictionary dictionaryWithObjectsAndKeys:[stack objectAtIndex:0], @"Name", [NSNumber numberWithBool:[[stack objectAtIndex:1] boolValue]], @"Value", line, @"command", nil]];
            }
            [stack removeAllObjects];
        }
        else
        {
            [stack addObject:line];
        }
    }
    NSDictionary * object = [NSDictionary dictionaryWithObjectsAndKeys:file, @"file", commands, @"commands", fileRec, @"rec", nil];
    //[stack release];
    //[commands release];
    
    return object;
}




-(void)processInlineUpdateFile:(NSDictionary *)object
{
    if (object == nil || [object valueForKey:@"file"] == nil)
    {
        [self.updateFiles removeAllObjects];
        return;
    }
    
    NSDictionary * fileRec = [object valueForKey:@"rec"];
    NSString * originalFile = [fileRec objectForKey:@"originalFile"];
    VBFolioStorage * storage = [self.mainServant.currentFolio firstStorage];
    
    if ([object valueForKey:@"content"] != nil)
    {
        if (storage != nil)
        {
            NSString * scriptToExecute = [object valueForKey:@"content"];
            NSLog(@"Executed script: %@", scriptToExecute);
            int result = [storage executeScript:scriptToExecute];
            NSLog(@"Executed with result: %d", result);
            if (result == SQLITE_OK)
            {
                NSString * key = [NSString stringWithFormat:@"last-update-%@", originalFile];
                NSNumber * lastUpdate = [fileRec valueForKey:@"update"];
                NSLog(@"update UserDefaults: %@ = %ld", key, (long)[lastUpdate integerValue]);
                NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
                [defs setInteger:[lastUpdate integerValue] forKey:key];
                
                // if script updates tables related to styles,
                // then invalidate styles cache
                NSRange findRange = [scriptToExecute rangeOfString:@"update styles_detail"];
                if (findRange.location != NSNotFound && self.mainServant.currentFolio != nil)
                {
                    [self.mainServant.currentFolio clearStylesCache];
                }
            }
        }
    }
    else if ([object valueForKey:@"commands"] != nil)
    {
        SQLiteCommand * sqlcmd = nil;
        NSString * cmdText = nil;
        NSUserDefaults * userDefs = [NSUserDefaults standardUserDefaults];
        NSArray * commands = [object valueForKey:@"commands"];
        @try {
            for (NSDictionary * cmd in commands)
            {
                cmdText = [cmd valueForKey:@"command"];
                if ([cmdText isEqualToString:@"BindString"]) {
                    int bindIndex = [(NSString *)[cmd valueForKey:@"BindIndex"] intValue];
                    [sqlcmd bindString:[cmd valueForKey:@"String"] toVariable:bindIndex];
                }
                else if ([cmdText isEqualToString:@"BindInteger"]) {
                    int bindIndex = [(NSString *)[cmd valueForKey:@"BindIndex"] intValue];
                    NSNumber * numb = [cmd valueForKey:@"Integer"];
                    [sqlcmd bindInteger:[numb intValue] toVariable:bindIndex];
                }
                else if ([cmdText isEqualToString:@"BindBlob"]) {
                    int bindIndex = [(NSString *)[cmd valueForKey:@"BindIndex"] intValue];
                    NSData * data = [cmd valueForKey:@"Blob"];
                    [sqlcmd bindData:data toVariable:bindIndex];
                }
                else if ([cmdText isEqualToString:@"SqlQueryDefine"]) {
                    if (sqlcmd)
                    {
                        //[sqlcmd release];
                        sqlcmd = nil;
                    }
                    sqlcmd = [storage createSqlCommand:[cmd valueForKey:@"Query"]];
                }
                else if ([cmdText isEqualToString:@"SqlQueryExecute"]) {
                    if (sqlcmd)
                    {
                        [sqlcmd execute];
                    }
                }
                else if ([cmdText isEqualToString:@"SetStringAppProperty"]) {
                    [userDefs setValue:[cmd valueForKey:@"Value"] forKey:[cmd valueForKey:@"Name"]];
                }
                else if ([cmdText isEqualToString:@"SetNumberAppProperty"]) {
                    NSNumber * numb = [cmd valueForKey:@"Value"];
                    [userDefs setInteger:[numb integerValue] forKey:[cmd valueForKey:@"Name"]];
                }
                else if ([cmdText isEqualToString:@"SetBoolAppProperty"]) {
                    NSNumber * numb = [cmd valueForKey:@"Value"];
                    [userDefs setBool:[numb boolValue] forKey:[cmd valueForKey:@"Name"]];
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        
        if (sqlcmd)
        {
            //[sqlcmd release];
            sqlcmd = nil;
        }
    }
    
    NSInteger index = [self.updateFiles indexOfObjectIdenticalTo:object];
    if (index > 0 && [self.updateFiles count] > index)
    {
        //NSLog(@"-removing file at index %ld", (long)index);
        [self.updateFiles removeObjectAtIndex:index];
    }
    else
    {
        //NSLog(@"-removing file at index ZERO");
        [self.updateFiles removeObjectAtIndex:0];
    }
    
    
    [self startDownloadingInlineUpdates];
    
}



@end
