//
//  FVPhotoshpFontMenu.h
//  ConceptualCase


#import <Cocoa/Cocoa.h>

@interface FVPhotoshpFontMenu : NSMenu
@property(strong)NSMenu* originalMenu;

- (id)initWithOriginalMenu:(NSMenu*)menu fontCollections:(NSArray*)fontCollections;


@end


@interface FVPhotoshpFontMenuItem : NSMenuItem
@property(strong)NSMenuItem* originalMenuItem;

- (id)initWithOriginalMenuItem:(NSMenuItem*)menuItem;


@end
