//
//  VBFileManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 26/07/14.
//
//

#import <Foundation/Foundation.h>
#import "FolioFileActive.h"
#import "FolioFileBase.h"


#define LISTSTATUS_UNINIT  0
#define LISTSTATUS_PENDING 1
#define LISTSTATUS_VALID   2
#define LISTSTATUS_ERROR   3

@class VBMainServant;
@class VBProductManager;

@interface VBFileManager : NSObject

@property (weak) IBOutlet VBMainServant* mainServant;
@property (weak) IBOutlet VBProductManager * productManager;

@property NSLock * enumerateFoliosLock;
@property NSLock * availableFoliosLock;
@property NSLock * dowloadListLock;
@property id availableFoliosRequestSender;

@property NSMutableArray * folioDocuments;

@property NSMutableArray * updateFiles;
@property NSMutableArray * folioList;
@property NSData * mainJavaScript;
@property NSMutableArray * folioFilesActive;
@property NSMutableArray * folioFilesAvailable;
@property NSMutableArray * folioFilesDownloaded;

@property BOOL enumerateFoliosDone;
@property BOOL enumerateFoliosPending;
@property BOOL remoteFilesError;
@property NSInteger enumerateFoliosStatus;
@property NSInteger folioListStatus;
@property NSInteger lastRemoteListRequestTime;

-(NSData *)mainTextJavaScript;
-(FolioFileBase *)fileForKey:(NSString *)aKey array:(NSArray *)array;
-(NSInteger)fileIndexForKey:(NSString *)aKey array:(NSArray *)array;
-(BOOL)enumerateFolios;
-(BOOL)reenumerateFolios;
-(void)resumeDownloading;
-(FolioFileBase *)anyFileWithName:(NSString *)strFile;
-(FolioFileDownloaded *)downloadedFileWithName:(NSString *)aName;
-(void)refreshLinksToDownloadedFiles;
-(void)startDownloadFile:(NSString *)fileName;
-(void)insertDownloadFile:(FolioFileDownloaded *)fileDown;
-(void)checkInlineUpdatesForFile;
-(void)removeActiveFileAtIndex:(NSInteger)index;
-(NSString *)documentsDirectory;

@end
