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

@implementation VBFileManager

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        self.folioDocuments = [[NSMutableArray alloc] init];
        self.mainJavaScript = nil;
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


#pragma mark -
#pragma mark list of local storage files




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

// returns YES, if there is at least one folio documents
-(NSString *)databasePath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * path = [NSBundle.mainBundle pathForResource:@"folio" ofType:@"ivd"];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"Folio file found");
        return path;
    } else {
        NSLog(@"Folio DOES NOT FOUND");
    }
    
    return nil;
}


@end
