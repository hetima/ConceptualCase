//
//  CCConceptualCase.m
//  ConceptualCase


#import "CCConceptualCase.h"
#import <objc/message.h>

#import "FVPhotoshpFontMenuCtl.h"
#import "FVFontCollectionManager.h"

@implementation CCConceptualCase

+(void)install
{
    NSString* bundleIdentifier=[[NSBundle mainBundle]bundleIdentifier];
    if ([bundleIdentifier isEqualToString:@"com.adobe.Photoshop"]) {
        [FVPhotoshpFontMenuCtl sharedInstance];
    }
    //[pm.fontCollectionManager fontCollections];
}


@end

IMP CCReplace_MethodImp_WithFunc(Class aClass, SEL origSel, const void* repFunc)
{
    Method origMethod;
    IMP oldImp = NULL;
    //extern void _objc_flush_caches(Class);
    
    if (aClass && (origMethod = class_getInstanceMethod(aClass, origSel))){
        oldImp=method_setImplementation(origMethod, repFunc);
        
    }
    //return original func pointer
    return oldImp;
}


IMP CCReplace_ClassMethodImp_WithFunc(Class aClass, SEL origSel, const void* repFunc)
{
    
    Method origMethod;
    IMP oldImp = NULL;
    extern void _objc_flush_caches(Class);
    
    if (aClass && (origMethod = class_getClassMethod(aClass, origSel))){
        oldImp=method_setImplementation(origMethod, repFunc);
        
        // Flush the method cache
        //_objc_flush_caches(aClass);
    }
	//return original func pointer
    return oldImp;
}
