//
//  VBFileManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 26/07/14.
//
//

#import <Foundation/Foundation.h>
//#import "FolioFileActive.h"
//#import "FolioFileBase.h"


#define LISTSTATUS_UNINIT  0
#define LISTSTATUS_PENDING 1
#define LISTSTATUS_VALID   2
#define LISTSTATUS_ERROR   3

@class VBMainServant;
@class VBProductManager;

@interface VBFileManager : NSObject

@property (weak) IBOutlet VBMainServant* mainServant;
@property (weak) IBOutlet VBProductManager * productManager;


@property NSMutableArray * folioDocuments;
@property NSData * mainJavaScript;



-(NSData *)mainTextJavaScript;
-(NSString *)databasePath;
-(NSString *)documentsDirectory;

@end
