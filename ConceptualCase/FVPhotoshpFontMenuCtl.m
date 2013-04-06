//
//  FVPhotoshpFontMenuCtl.m
//  ConceptualCase


#import "FVPhotoshpFontMenuCtl.h"
#import "CCConceptualCase.h"
#import "FVFontCollectionManager.h"
#import "FVPhotoshpFontMenu.h"


/*
 @interface PSCocoaMenuItem : NSMenuItem
 {
 struct ZMenuItem *fRefCon;
 unsigned char fManuallyDisabled;
 BOOL fEnabled;
 int fSubMenuID;
 long long fItemCmd;
 int fItemIcon;
 BOOL fProcessingShortcut;
 }
 
 - (void)dealloc;
 - (id)initWithCommandID:(long long)arg1 withRefCon:(struct ZMenuItem *)arg2 title:(id)arg3 action:(SEL)arg4 keyEquivalent:(id)arg5;
 - (id)init;
 - (id)initWithTitle:(id)arg1 action:(SEL)arg2 keyEquivalent:(id)arg3;
 - (void)setFRefCon:(struct ZMenuItem *)arg1;
 - (void *)fRefCon;
 - (void)setSubMenuID:(long long)arg1;
 - (long long)getSubMenuID;
 - (void)menuEventHandler:(id)arg1;
 - (BOOL)validateMenuItem:(id)arg1;
 - (void)handleQuit:(id)arg1;
 - (BOOL)isSeparatorItem;
 - (void)setHandlesEventFlag;
 @property BOOL fProcessingShortcut; // @synthesize fProcessingShortcut;
 @property int fItemIcon; // @synthesize fItemIcon;
 @property long long fItemCmd; // @synthesize fItemCmd;
 @property BOOL fEnabled; // @synthesize fEnabled;
 @property unsigned char fManuallyDisabled; // @synthesize fManuallyDisabled;
 
 @end
 
 
 */



//- (void)attachPopUpWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
void (*orig_attachPopUpWithFrame)(id, SEL, NSRect, id);
static void ST_attachPopUpWithFrame(id self, SEL _cmd, NSRect r, id i)
{
    orig_attachPopUpWithFrame(self, _cmd, r, i);
    [[FVPhotoshpFontMenuCtl sharedInstance]menuCellWillPopup:self];
}

@implementation FVPhotoshpFontMenuCtl
-(long long)fItemCmd{
    return 0;
}

+ (FVPhotoshpFontMenuCtl*)sharedInstance
{
    static FVPhotoshpFontMenuCtl *sharedInstance;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[FVPhotoshpFontMenuCtl alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {

        self.fontCollectionManager=[[FVFontCollectionManager alloc]init];
        [self.fontCollectionManager fontCollections];
        Class psPopup=NSClassFromString(@"PSCocoaMenu");
        if (psPopup) {
            orig_attachPopUpWithFrame=(void (*)(id, SEL, NSRect, id))
                RMF([NSPopUpButtonCell class], @selector(attachPopUpWithFrame:inView:), ST_attachPopUpWithFrame);
        }
    }
    return self;
}

- (void)menuCellWillPopup:(NSPopUpButtonCell*)btnCell
{
    NSMenu* menu=[btnCell menu];
    if ([menu numberOfItems]<=0) {
        return;
    }
    
    //メニュー項目がフォント名と一致するかどうかでフォントメニューを識別
    //とりあえず8個くらい一致したらフォントメニューと見做す
    NSArray* items=[menu itemArray];
    NSArray* fonts=[self.fontCollectionManager allFonts];
    NSInteger fontFound=0;
    for (NSMenuItem* item in items) {
        if ([item view]==nil) { //font menu item has PSCocoaMenuItemView
            break;
        }
        if ([fonts containsObject:[item title]]) {
            fontFound++;
            if (fontFound>8) {
                break;
            }
        }
    }

    if (fontFound>8) {
        LOG(@"seems font menu");
        NSArray* fontCollections=[self.fontCollectionManager fontCollections];
        FVPhotoshpFontMenu* repMenu=[[FVPhotoshpFontMenu alloc]initWithOriginalMenu:menu fontCollections:fontCollections];
        [btnCell setMenu:repMenu];
    }
    
}


@end
