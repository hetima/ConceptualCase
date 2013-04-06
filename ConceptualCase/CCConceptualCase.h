//
//  CCConceptualCase.h
//  ConceptualCase


#import <Cocoa/Cocoa.h>

@interface CCConceptualCase : NSObject

@end

IMP CCReplace_MethodImp_WithFunc(Class aClass, SEL origSel, const void* repFunc);
IMP CCReplace_ClassMethodImp_WithFunc(Class aClass, SEL origSel, const void* repFunc);

#ifndef REPFUNCDEFd
#define REPFUNCDEFd
#define RMF(aClass, origSel, repFunc) CCReplace_MethodImp_WithFunc(aClass, origSel, repFunc)
#define RCMF(aClass, origSel, repFunc) CCReplace_ClassMethodImp_WithFunc(aClass, origSel, repFunc)
#endif
