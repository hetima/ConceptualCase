//
//  FVPhotoshpFontMenu.m
//  ConceptualCase


#import "FVPhotoshpFontMenu.h"
#import <objc/message.h>

@implementation FVPhotoshpFontMenu{
    NSTimer* _timer;
}

- (id)initWithOriginalMenu:(NSMenu*)menu fontCollections:(NSArray*)fontCollections
{
    self = [super initWithTitle:@""];
    if (self) {
        _timer=nil;
        self.originalMenu=menu;
        NSMenuItem* subItem=[self addItemWithTitle:@"All Fonts" action:nil keyEquivalent:@""];
        [subItem setSubmenu:menu];
        [subItem setOnStateImage:[subItem offStateImage]];
        
        [self addFontCollections:fontCollections];
        [self addManageFontCollectionMenuItem];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuStart:) name:NSMenuDidBeginTrackingNotification object:self];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuEnd:) name:NSMenuDidEndTrackingNotification object:self];
    }
    return self;
}

- (void)addFontCollections:(NSArray*)fontCollections
{
    [self insertSeparatorToEnd];
    for (NSDictionary* coll in fontCollections) {
        NSString* name=[coll objectForKey:@"name"];
        if ([name hasPrefix:@"com.apple."]){
            continue;
        }
        NSArray* fonts=[coll objectForKey:@"fonts"];
        NSMenu* subMenu=[[NSMenu alloc]initWithTitle:name];
        for (NSString* fontFamily in fonts) {
            NSMenuItem* originalItem=[self originalMenuItemForFontFamily:fontFamily];
            if (originalItem) {
                FVPhotoshpFontMenuItem* item=[[FVPhotoshpFontMenuItem alloc]initWithOriginalMenuItem:originalItem];
                [subMenu addItem:item];
            }
        }
        if ([subMenu numberOfItems]>0) {
            NSMenuItem* subItem=[self addItemWithTitle:name action:nil keyEquivalent:@""];
            [subItem setSubmenu:subMenu];
        }
    }
    [self removeSeparatorFromEnd];
}

- (void)addManageFontCollectionMenuItem
{
    [self insertSeparatorToEnd];
    NSMenuItem* subItem=[self addItemWithTitle:@"Manage Font Collections" action:@selector(actManageFontCollections:) keyEquivalent:@""];
    [subItem setTarget:self];

}

- (void)dealloc
{
    if (_timer) {
        [_timer invalidate];
        _timer=nil;
    }
}

//PSCocoaMenu の menuIdleTimerDidFire: を呼んでフォントプレビューを作成する
- (void)menuStart:(NSNotification*)note
{
    if (_timer==nil) {
        _timer=[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(menuIdleTimerDidFire:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSEventTrackingRunLoopMode];
    }
}

- (void)menuEnd:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSMenuDidBeginTrackingNotification object:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSMenuDidEndTrackingNotification object:self];
    [_timer invalidate];
    _timer=nil;
}

- (void)menuIdleTimerDidFire:(NSTimer*)timer
{
    if ([self.originalMenu respondsToSelector:@selector(menuIdleTimerDidFire:)]) {
        [(id)self.originalMenu menuIdleTimerDidFire:timer];
    }
}


- (NSMenuItem*)originalMenuItemForFontFamily:(NSString*)fontFamily
{
    NSArray* items=[self.originalMenu itemArray];
    for (NSMenuItem* item in items) {
        if ([[item title]isEqualToString:fontFamily]) {
            return item;
        }
    }
    return nil;
}

- (void)insertSeparatorToEnd
{
    if ([self numberOfItems]>0) {
        NSMenuItem* lastItem=[self itemAtIndex:[self numberOfItems]-1];
        if (![lastItem isSeparatorItem]) {
            [self addItem:[NSMenuItem separatorItem]];
        }
    }
}

- (void)removeSeparatorFromEnd
{
    if ([self numberOfItems]>0) {
        NSInteger end=[self numberOfItems]-1;
        NSMenuItem* lastItem=[self itemAtIndex:end];
        if ([lastItem isSeparatorItem]) {
            [self removeItemAtIndex:end];
        }
    }
}


-(IBAction)actManageFontCollections:(id)sender
{
    NSString* appPath=@"/Applications/Font Book.app";
    [[NSWorkspace sharedWorkspace]launchApplication:appPath];
}

@end


@implementation FVPhotoshpFontMenuItem

- (id)initWithOriginalMenuItem:(NSMenuItem *)menuItem
{
    self = [super initWithTitle:[menuItem title] action:@selector(menuEventHandler:) keyEquivalent:@""];
    if (self) {
        self.originalMenuItem=menuItem;
        [self setTarget:self];
        [self setState:[menuItem state]];
        //[self setView:[menuItem view]];
    }
    return self;
}


- (void)menuEventHandler:(id)sender
{
    NSMenu* menu=[self.originalMenuItem menu];
    NSInteger idx=[menu indexOfItem:self.originalMenuItem];
    [menu performActionForItemAtIndex:idx];
}

@end