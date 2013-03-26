//
//  NSDog.m
//  NSDog
//
//  Created by Christopher Larsen and Brian Croom on 2013-03-12.
//  Copyright (c) 2013 All rights reserved
//

#import "NSDog.h"
#import <objc/runtime.h>


static char kDogHouse;
static char kObjectObserved;

typedef enum {
    kDog      = 0,
    kWatchDog = 1,
    kGuardDog = 2,
    kDeadDog  = -1
} kDogType;

@interface Dog ()

+(void)attachDogTo:(id)object keypath:(NSString*)keypath;

@property (assign) kDogType dogType;

@property (nonatomic, strong) NSString* keypath;
@property (nonatomic, weak)   id objectObserved;
@property (nonatomic, weak)   id receiver;
@property (assign)            float upperLimit;
@property (assign)            float lowerLimit;

@end


void NSDog(id object, NSString* keypath)
{
    [Dog attachDogTo: object keypath: keypath];
}


@implementation Dog

+(void)attachDogTo:(NSObject*)object keypath:(NSString*)keypath
{
    if (object && [[object class] isSubclassOfClass: [Dog class]] == NO)
        [[[Dog alloc] init] attatchDogTo:object andKeypath:keypath];
}

+(Dog*)watchDogForObject:(id)object keypath:(NSString*)keypath relayObservedChangesTo:(id)receiver
{
    if (object == nil || keypath == nil || receiver ==  nil) return nil;
        
    Dog* dog = [[Dog alloc] init];
    if (dog) {
        [dog setDogType: kWatchDog];
        [dog setReceiver: receiver];
        [dog attatchDogTo:object andKeypath:keypath];
    }
    return dog;
}

+(Dog*)guardDogForObject:(id)object keypath:(NSString*)keypath lowerLimit:(CGFloat)lowerLimit upperLimit:(CGFloat)upperLimit
{
    if (object == nil || keypath == nil) return nil;
    
    Dog* dog = [[Dog alloc] init];
    if (dog) {
        [dog setDogType: kGuardDog];
        [dog setLowerLimit:lowerLimit];
        [dog setUpperLimit:upperLimit];
        [dog attatchDogTo:object andKeypath:keypath];
    }
    return dog;    
}


+(BOOL)removeDogFrom:(id)object forKeypath:(NSString*)keypath
{
    if (object == nil) return NO;
    
    NSMutableSet* doghouse = objc_getAssociatedObject(object, &kDogHouse);
    if (doghouse == nil) return NO;
 
    Dog* dogToRemove = nil;
    BOOL dogRemoved  = NO;

    @synchronized(object) {
        
        do {
            dogToRemove = nil;
            for (Dog* dog in doghouse) {
                if (keypath == nil || [dog.keypath isEqualToString: keypath]) {
                    dogToRemove = dog;
                    dogRemoved  = YES;
                    break;
                }
            }
            if (dogToRemove) {
                [dogToRemove detatchDog];
                [doghouse removeObject: dogToRemove];
            }
        } while (dogToRemove);
        
        if (doghouse.count == 0) objc_setAssociatedObject(object, &kDogHouse, nil, OBJC_ASSOCIATION_ASSIGN);
        
    }
    
    return dogRemoved;
}

- (void)attatchDogTo:(id)object andKeypath:(NSString*)keypath
{
    if (object == nil || [[object class] isSubclassOfClass: [Dog class]]) return;
    
    self.objectObserved = object;
    self.keypath        = keypath;

    @synchronized(object) {
        
        NSMutableSet* doghouse = objc_getAssociatedObject(object, &kDogHouse);
        if (doghouse == nil) {
            doghouse = [[NSMutableSet alloc] initWithCapacity:0];
            objc_setAssociatedObject(object, &kDogHouse, doghouse, OBJC_ASSOCIATION_RETAIN);
        }
        [doghouse addObject: self];
        
    }
    
    if (keypath) [object addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setObjectObserved:(id)objectObserved
{
    objc_setAssociatedObject(self, &kObjectObserved, objectObserved, OBJC_ASSOCIATION_ASSIGN);
}

- (id)objectObserved
{
    return objc_getAssociatedObject(self, &kObjectObserved);
}

// Override of KVO NSObject method
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    if (self.dogType == kWatchDog) {
        
        if (self.receiver) {
            @try {
                [self.receiver observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            }
            @catch (NSException* exception) {
                if ([exception.name isEqualToString: NSInternalInconsistencyException]) {
                    NSLog(@"ERROR: Dog's KVO receiver must implement the KVO override observeValueForKeyPath:ofObject:change:context:");
                    kill(getpid(), SIGSTOP);
                }
            }
        } else {
            [self detatchDog];
        }
        return;
    }
    
    NSNumber* keyValueChangeNewKey = [change objectForKey: NSKeyValueChangeNewKey];
    
    if (keyValueChangeNewKey && keyValueChangeNewKey.class != NSNull.class) {
        
        if (self.dogType == kGuardDog) {
            
            if ([keyValueChangeNewKey floatValue] < self.lowerLimit)
                [self bark:[NSString stringWithFormat:@"exceeded lower limit: %@",[keyValueChangeNewKey stringValue]]];
            
            if ([keyValueChangeNewKey floatValue] > self.upperLimit)
                [self bark:[NSString stringWithFormat:@"exceeded upper limit: %@",[keyValueChangeNewKey stringValue]]];
            
        } else {
            
            [self bark:[NSString stringWithFormat: @"changed value: %@", [keyValueChangeNewKey stringValue]]];
            
        }

    } else {
        
        [self bark:@"is nil"];
        
    }
    
}

- (void)bark:(NSString*)message
{
    if (self.dogType != kDeadDog) {
        NSLog(@"Bark! %@.%@ %@", [self.objectObserved class], self.keypath, message);
        if (self.breakpointOnBark) kill(getpid(), SIGSTOP);
    }
}

- (void)detatchDog
{
    if (self.objectObserved && self.keypath)  {
        [self.objectObserved removeObserver:self forKeyPath:self.keypath];
        [self setObjectObserved: nil];
    }
    self.dogType = kDeadDog;
}

- (void)dealloc
{
    NSLog(@"Bark! %@ %@", [self.objectObserved class], @"deallocated");
    [self detatchDog];
    if (_breakpointOnDealloc) kill(getpid(), SIGSTOP);
}

@end
