//
//  NSDog.h
//  NSDog
//
//  Created by Christopher Larsen, Brian Croom on 2013-03-12.
//  Copyright (c) 2013 All rights reserved


/* //////////////////////////////////////////////////////////////////////////////////////////////
 
 NSDog
 
 void NSDog(id object, NSString* keypath);
 
 * NSDog attatches a Key-Value-Observing Dog object for the keypath specified.
 * Any changes to that keypath are observed and logged to the console
 * A console message is logged when the observed object is deallocated
 * You may specify nil for the keypath, in which case only deallocation of the object will be logged.
 * Use NSDog() as a replacement for NSLog() for continuous logging of changes to an object's property
 
 
 +(Dog*)watchDogForObject:(id)object keypath:(NSString*)keypath relayObservedChangesTo:(id)receiver;
 
 * Attatches a Dog to an object to observes changes.
 * If a receiver is provided all KVO observeValueForKeyPath:ofObject:change:context: calls are redirected to it.
 * The receiver MUST implement the standard KVO override observeValueForKeyPath:ofObject:change:context:
 * BOOL barkWhenObjectIsDeallocated - Enable log message when observed object is deallocated. (Default: YES)
 * BOOL breakpointOnBark - Enables a breakpoint whenever a change is observed for the object. (Default: NO)
 * BOOL breakpointOnDealloc - Enables a breakpoint when the observed object is deallocated.   (Default: NO)
 
 
 + (Dog*)guardDogForObject:(id)object keypath:(NSString*)keypath lowerLimit:(CGFloat)lowerLimit upperLimit:(CGFloat)upperLimit;
 
 * Attaches a Dog to an object keypath of scalar type (BOOL, NSInteger, char, float ...)
 * When a KVO change to the observed object exceeds the upper or lower limits a console warning message is logged
 
 
 + (Dog*)callbackDogForObject:(id)object keypath:(NSString *)keypath observer:(id)observer callback:(SEL)callback;
 
 * Attaches a Dog to an object keypath of scalar type (BOOL, int, float ...)
 * When a KVO change to the observed object exceeds the upper or lower limits a console warning message is logged
 
 + (Dog*)blockDogForObject:(id)object keypath:(NSString *)keypath changeBlock:(void (^)(void))changeBlock;
 
 * Attaches a Dog to an object keypath with a copy of the block
 * The block will execute on every change to the objects keypath
 * To avoid retaining self strongly, define and pass a weakly retained reference to self as the object:
 __weak typeof(self) weakSelf = self;
 
 + (int)removeDogFrom:(id)object forKeypath:(NSString*)keypath;
 
 * Remove all Dog's from an object for the given keypath
 * Returns the number of Dog's removed for the keypath
 * Pass nil for keypath to remove all Dog's for all keypath's from the observed object.
 
 
 
 NSObject Category for NSDog, 
 
 - (BOOL)addObserver:(id)observer forKeyPath:(NSString *)keyPath callback:(SEL)callback;
 * Convenience method that creates a kCallbackDog type Dog
 * Use this category on NSObject to make the observer perform a selector you provide

 
 - (BOOL)addObserver:(__weak id)weakObserver forKeyPath:(NSString *)keyPath block:(void(^)(void))executionBlock;
 * Convenience methid that creates a kBlockDog type Dog
 * Use this category on NSObject to execute a block for changes to the objects keypath.
 
 - (BOOL)bindKeypath:(NSString*)keypath toBlock:(void(^)(void))executionBlock;
 * Bind any two things together. (Frames, centers, states) Behaviour when two keypaths are not the same kind is undefined.
 
 /////////////////////////////////////////////////////////////////////////////////////////////// */

#import <Foundation/Foundation.h>

@interface Dog : NSObject

@property BOOL barkWhenObjectIsDeallocated;
@property BOOL disableBreakpointOnBark;
@property BOOL disableBreakpointOnDealloc;
@property BOOL muzzled;

+ (Dog*)dogAttachedTo:(id)object keypath:(NSString*)keypath;
+ (Dog*)watchDogForObject:(id)object keypath:(NSString*)keypath relayObservedChangesTo:(id)receiver;
+ (Dog*)guardDogForObject:(id)object keypath:(NSString*)keypath lowerLimit:(CGFloat)lowerLimit upperLimit:(CGFloat)upperLimit;
+ (Dog*)callbackDogForObject:(id)object keypath:(NSString *)keypath observer:(id)observer callback:(SEL)callback;
+ (Dog*)blockDogForObject:(id)object keypath:(NSString *)keypath changeBlock:(void (^)(void))changeBlock;
+ (NSInteger)removeDogsFrom:(id)object forKeypath:(NSString*)keypath;

@end

void NSDog(id object, NSString* keypath);


/* /////////////////////////////// NSObject Category for NSDog /////////////////////////////////////// */

@interface NSObject (NSDogCategory)

- (BOOL)addObserver:(id)observer forKeyPath:(NSString *)keyPath callback:(SEL)callback;
- (BOOL)addObserver:(__weak id)weakObserver forKeyPath:(NSString *)keyPath block:(void(^)(void))executionBlock;

- (BOOL)bindKeypath:(NSString*)keypath toBlock:(void(^)(void))executionBlock;

- (BOOL)bindToTargetObject:(id)objectTarget
             targetKeypath:(NSString*)targetKeypath
                 toKeypath:(NSString*)keypath
             bidirectional:(BOOL)bidirectional;

@end


