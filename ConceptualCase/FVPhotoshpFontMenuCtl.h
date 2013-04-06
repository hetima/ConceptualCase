//
//  FVPhotoshpFontMenuCtl.h
//  ConceptualCase


#import <Foundation/Foundation.h>

@class FVFontCollectionManager;

@interface FVPhotoshpFontMenuCtl : NSObject
@property(strong)FVFontCollectionManager* fontCollectionManager;

+ (FVPhotoshpFontMenuCtl*)sharedInstance;
- (void)menuCellWillPopup:(NSPopUpButtonCell*)btnCell;

@end
