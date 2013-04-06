//
//  FVFontCollectionManager.m
//  ConceptualCase



#import "FVFontCollectionManager.h"


#define FVFSEventStreamLatency			((CFTimeInterval)3.0)

static void FVFSEventsCallback(
                               ConstFSEventStreamRef streamRef,
                               void *callbackCtxInfo,
                               size_t numEvents,
                               void *eventPaths, // CFArrayRef
                               const FSEventStreamEventFlags eventFlags[],
                               const FSEventStreamEventId eventIds[])
{
	FVFontCollectionManager *watcher			= (__bridge FVFontCollectionManager *)callbackCtxInfo;
    [watcher fileSystemChanged];
	
    
}




@implementation FVFontCollectionManager
{
    FSEventStreamRef _eventStream;
    NSArray* _fontCollections;
    NSArray* _allFonts;
}

- (NSArray*)fontCollections
{
    if (_fontCollections==nil) {
        [self loadFromCollection];
    }
    return _fontCollections;
}

- (NSArray*)allFonts
{
    if (_allFonts==nil) {
        [self loadFromCollection];
    }
    return _allFonts;
}

- (void)loadFromCollection
{
    
    NSArray* names=[[NSFontManager sharedFontManager]collectionNames];
    NSMutableArray* ary=[NSMutableArray arrayWithCapacity:[names count]];
    
    for (NSString* name in names) {
        if ([name isEqualToString:@"com.apple.AllFonts"]) {
            //array of NSFontDescriptor
            NSArray* descs=[[NSFontManager sharedFontManager]fontDescriptorsInCollection:name];
            _allFonts=[self fontFamiliesWithDescriptors:descs];
        }else if (![name hasPrefix:@"com.apple."]) {
            NSArray* descs=[[NSFontManager sharedFontManager]fontDescriptorsInCollection:name];
            NSArray* fonts=[self fontFamiliesWithDescriptors:descs];
            if (name && [fonts count]) {
                NSDictionary* dict=@{@"name": name, @"fonts":fonts};
                [ary addObject:dict];
            }
        }
        _fontCollections=ary;
    }
}

- (NSArray*)fontFamiliesWithDescriptors:(NSArray*)descs
{
    NSMutableArray* ary=[NSMutableArray arrayWithCapacity:[descs count]];
    for (NSFontDescriptor* desc in descs) {
        NSString* name=[desc objectForKey:NSFontFamilyAttribute];
        if (![ary containsObject:name]) {
            [ary addObject:name];
        }
    }
    return ary;
}


- (id)init
{
    self = [super init];
    if (self) {
        _eventStream = nil;
        _fontCollections=nil;
        [self setupEventStream];
    }
    return self;
}


- (void)dealloc
{
    _fontCollections=nil;
    _allFonts=nil;
    [self invalidateEventStream];
}

- (void)setupEventStream
{
    [self invalidateEventStream];
    
    FSEventStreamCreateFlags   flags = (kFSEventStreamCreateFlagUseCFTypes |
                                        kFSEventStreamCreateFlagWatchRoot);
    flags |= kFSEventStreamCreateFlagFileEvents;
    
    NSString* path=[@"~/Library/FontCollections" stringByStandardizingPath];
    NSArray* watchPaths=@[path];
    
	FSEventStreamContext callbackCtx;
	callbackCtx.version			= 0;
	callbackCtx.info			= (__bridge void *)self;
	callbackCtx.retain			= NULL;
	callbackCtx.release			= NULL;
	callbackCtx.copyDescription	= NULL;
    
	_eventStream = FSEventStreamCreate(kCFAllocatorDefault,
									   &FVFSEventsCallback,
									   &callbackCtx,
									   (__bridge CFArrayRef)watchPaths,
									   kFSEventStreamEventIdSinceNow,
									   FVFSEventStreamLatency,
									   flags);
    FSEventStreamScheduleWithRunLoop(_eventStream, [[NSRunLoop currentRunLoop]getCFRunLoop], kCFRunLoopDefaultMode);
    if (!FSEventStreamStart(_eventStream)) {
        
    }
}

- (void)invalidateEventStream
{
    if (_eventStream) {
        FSEventStreamStop(_eventStream);
        FSEventStreamInvalidate(_eventStream);
        FSEventStreamRelease(_eventStream);
        _eventStream = nil;
    }
}


-(void)fileSystemChanged
{
    _fontCollections=nil;
    _allFonts=nil;
}

@end
