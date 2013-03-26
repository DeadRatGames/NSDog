//
//  NSDog.h
//  NSDog
//
//  Created by Christopher Larsen and Brian Croom on 2013-03-12.
//  Copyright (c) 2013 All rights reserved
//

/* //////////////////////////////////////////////////////////////////////////////////////////////

  NSDog
 
  void NSDog(id object, NSString* keypath);
 
  * NSDog attatches a Key-Value-Observing Dog object for the keypath specified.
  * Any changes to that keypath are observed and logged to the console.
  * Dog's log a console message when their observed object is deallocated.
  * You may specify nil for the keypath, in which case only deallocation of the object will be logged.
  * If the observed object is deallocated, the Dog is removed and safely released beforehand.
  * Use NSDog() as a replacement for NSLog() for continuous logging of an object's property for
    the life of the object.

 
  +(Dog*)watchDogForObject:(id)object keypath:(NSString*)keypath relayObservedChangesTo:(id)receiver;
 
  * Attatches a kWatchDog Dog to an object and relays all the standard KVO change notifications to a receiver.
  * The receiver MUST implement the standard KVO override observeValueForKeyPath:ofObject:change:context:
  * Set a Dog's breakpointOnBark to break in the debugger every time a KVO change is observed for the object.
  * Set a Dog's breakpointOnDealloc to break in the debugger when the observed object is deallocated.


 + (Dog*)guardDogForObject:(id)object keypath:(NSString*)keypath lowerLimit:(CGFloat)lowerLimit upperLimit:(CGFloat)upperLimit;
 
  * Attaches a kGuardDog Dog to an object keypath of scalar type (BOOL, int, float ...)
  * When a KVO change to the observed object exceeds the upper or lower limits a console warning message is logged
  * Use kGuardDog to ensure an observed object stays withing set limits

 
 + (BOOL)removeDogFrom:(id)object forKeypath:(NSString*)keypath;

  * Remove any Dog's from an object for the given keypath.
  * Pass nil for keypath to remove all Dog's for all keypath's from the observed object.
 
 
/////////////////////////////////////////////////////////////////////////////////////////////// */

#import <Foundation/Foundation.h>

void NSDog(id object, NSString* keypath);

@interface Dog : NSObject

@property (assign) BOOL breakpointOnBark;
@property (assign) BOOL breakpointOnDealloc;

+ (Dog*)watchDogForObject:(id)object keypath:(NSString*)keypath relayObservedChangesTo:(id)receiver;
+ (Dog*)guardDogForObject:(id)object keypath:(NSString*)keypath lowerLimit:(CGFloat)lowerLimit upperLimit:(CGFloat)upperLimit;
+ (BOOL)removeDogFrom:(id)object forKeypath:(NSString*)keypath;

@end
