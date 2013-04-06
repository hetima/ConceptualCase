//
//  FVFontCollectionManager.h
//  ConceptualCase



#import <Foundation/Foundation.h>

@interface FVFontCollectionManager : NSObject


- (NSArray*)fontCollections;
- (NSArray*)allFonts;


- (void)setupEventStream;
- (void)invalidateEventStream;
- (void)fileSystemChanged;

@end
