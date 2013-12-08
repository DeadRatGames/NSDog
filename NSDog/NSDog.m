//
//  NSDog.m
//  NSDog
//
//  Created by Christopher Larsen, Brian Croom on 2013-03-12.
//  Copyright (c) 2013 All rights reserved


#import "NSDog.h"
#import <objc/runtime.h>

typedef enum {
	kDeadDog    = -1,
	kDog        =  0,
	kWatchDog   =  1,
	kGuardDog   =  2,
	kBlockDog   =  3,
	kCallbackDog = 4
} kDogType;


@interface Dog ()

@property (assign) kDogType dogType;

@property (nonatomic, weak) id objectObserved;
@property (nonatomic, weak) id receiver;
@property (nonatomic) NSString *keypath;
@property (nonatomic, copy) void (^changeBlock)(void);
@property CGFloat upperGuardLimit;
@property CGFloat lowerGuardLimit;
@property SEL callback;

@end

#pragma mark - NSDog Convenience Method

void NSDog(id object, NSString *keypath)
{
	[Dog dogAttachedTo:object keypath:keypath];
}

#pragma mark - Dog

@implementation Dog

static char kDogHouse;
static char kObjectObserved;

+ (Dog *)dogAttachedTo:(NSObject *)object keypath:(NSString *)keypath
{
	return [[Dog alloc] initWithObservedObject:object andKeypath:keypath];
}

+ (Dog *)watchDogForObject:(id)object keypath:(NSString *)keypath relayObservedChangesTo:(id)receiver
{
	Dog *dog = [[Dog alloc] initWithObservedObject:object andKeypath:keypath];
	if (receiver) {
		[dog setDogType:kWatchDog];
		[dog setReceiver:receiver];
	}
	return dog;
}

+ (Dog *)guardDogForObject:(id)object keypath:(NSString *)keypath lowerLimit:(CGFloat)lowerLimit upperLimit:(CGFloat)upperLimit
{
	if (object == nil || keypath == nil) return nil;
    
	NSObject *checkType = [object valueForKeyPath:keypath];
	if (checkType == nil || [checkType.class isSubclassOfClass:[NSNumber class]] == NO) {
		NSLog(@"Cannot guard limits for non-NSNumber's");
		return nil;
	}
    
	Dog *dog = [[Dog alloc] initWithObservedObject:object andKeypath:keypath];
	[dog setDogType:kGuardDog];
	[dog setLowerGuardLimit:lowerLimit];
	[dog setUpperGuardLimit:upperLimit];
    
	return dog;
}

+ (Dog *)blockDogForObject:(id)object keypath:(NSString *)keypath changeBlock:(void (^)(void))changeBlock
{
	if (object == nil || keypath == nil || changeBlock == nil) return nil;
    
	Dog *blockDog = [[Dog alloc] initWithObservedObject:object andKeypath:keypath];
    [blockDog setDogType:kBlockDog];
	[blockDog setChangeBlock:changeBlock];
    
	return blockDog;
}

+ (Dog *)callbackDogForObject:(id)object keypath:(NSString *)keypath observer:(id)observer callback:(SEL)callback
{
	if (object == nil || keypath == nil || observer == nil || callback == nil) {
		return nil;
	}
    
	Dog *selectDog = [Dog dogAttachedTo:object keypath:keypath];
	[selectDog setDogType:kCallbackDog];
	[selectDog setReceiver:observer];
	[selectDog setCallback:callback];
    
	return selectDog;
}

+ (int)removeDogsFrom:(id)object forKeypath:(NSString *)keypath
{
	if (object == nil) {
		return NO;
	}
    
	NSMutableSet *doghouse = objc_getAssociatedObject(object, &kDogHouse);
	if (doghouse == nil) {
		return NO;
	}
    
	Dog *dogToRemove = nil;
	int dogsRemoved  = 0;
    
	@synchronized(object) {
        
		do {
			dogToRemove = nil;
			for (Dog *dog in doghouse) {
				if (keypath == nil || [dog.keypath isEqualToString:keypath]) {
					dogToRemove = dog;
					break;
				}
			}
            
			if (dogToRemove) {
				dogsRemoved++;
				[dogToRemove detatchDog];
				[doghouse removeObject:dogToRemove];
			}
            
		} while (dogToRemove);
        
		if (doghouse.count == 0) {
			objc_setAssociatedObject(object, &kDogHouse, nil, OBJC_ASSOCIATION_ASSIGN);
		}
        
	}
    
	return dogsRemoved;
}

+ (Dog *)muzzleDogAttachedToObject:(id)object keypath:(NSString *)keypath
{
	if (object == nil) {
		return nil;
	}
    
	NSMutableSet *doghouse = objc_getAssociatedObject(object, &kDogHouse);
	if (doghouse == nil) {
		return nil;
	}
    
	@synchronized(object) {
        
		for (Dog *dogToMuzzle in doghouse) {
			if ([dogToMuzzle.keypath isEqualToString:keypath]) {
				[dogToMuzzle stopObserving];
				return dogToMuzzle;
			}
		}
        
	}
    
	return nil;
}

- (id)initWithObservedObject:(id)object andKeypath:(NSString *)keypath
{
	if (object == nil || [[object class] isSubclassOfClass:[Dog class]] == YES) {
		return nil;
	}
    
	if ((self = [super init])) {
        
		self.objectObserved          = object;
		_keypath                     = keypath;
		_barkWhenObjectIsDeallocated = NO;
        
		@synchronized(object) {
            
			NSMutableSet *doghouse = objc_getAssociatedObject(object, &kDogHouse);
			if (doghouse == nil) {
				doghouse = [[NSMutableSet alloc] initWithCapacity:0];
				objc_setAssociatedObject(object, &kDogHouse, doghouse, OBJC_ASSOCIATION_RETAIN);
			}
			[doghouse addObject:self];
            
		}
        
		[self beginObserving];
        
	}
    
	return self;
}

- (void)setObjectObserved:(id)objectObserved
{
	objc_setAssociatedObject(self, &kObjectObserved, objectObserved, OBJC_ASSOCIATION_ASSIGN);
}

- (void)beginObserving
{
	if (_keypath) {
		[self.objectObserved addObserver:self forKeyPath:_keypath options:NSKeyValueObservingOptionNew context:nil];
	}
}

- (void)stopObserving
{
	[self.objectObserved removeObserver:self forKeyPath:_keypath];
}

- (id)objectObserved
{
	return objc_getAssociatedObject(self, &kObjectObserved);
}

// Override of standard KVO method of NSObject
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	NSNumber *keyValueChangeNewKey = [change objectForKey:NSKeyValueChangeNewKey];
    
	switch (_dogType) {
            
        case kWatchDog:
            
            if (_receiver) {
                
                @try {
                    [self.receiver observeValueForKeyPath:keyPath ofObject:object change:change context:context];
                }
                
                @catch (NSException *exception) {
                    if ([exception.name isEqualToString:NSInternalInconsistencyException]) {
                        NSLog(@"ERROR: Dog's KVO receiver must implement the KVO override observeValueForKeyPath:ofObject:change:context:");
                        kill(getpid(), SIGSTOP);
                    }
                }
                
            } else {
                
                [self detatchDog];
                
            }
            
            break;
            
        case kBlockDog:
            
            if (_changeBlock) {
                _changeBlock();
            }
            
            break;
            
        case kCallbackDog:
            
            if (_receiver && _callback && [_receiver respondsToSelector:_callback]) {
                
                // Supress XCode warnings for dynamic selectors
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [_receiver performSelector:_callback withObject:self.objectObserved];
#pragma clang diagnostic pop
                
            } else {
                
                [self detatchDog];
                
            }
            
            break;
            
        case kGuardDog:
            
            if (keyValueChangeNewKey && keyValueChangeNewKey.class != NSNull.class) {
                
                if ([keyValueChangeNewKey isKindOfClass:[NSNumber class]] && [keyValueChangeNewKey respondsToSelector:@selector(floatValue)]) {
                    
                    if ([keyValueChangeNewKey floatValue] < _lowerGuardLimit)
                        [self bark:[NSString stringWithFormat:@"exceeded lower limit: %@", [keyValueChangeNewKey stringValue]]];
                    
                    if ([keyValueChangeNewKey floatValue] > _upperGuardLimit)
                        [self bark:[NSString stringWithFormat:@"exceeded upper limit: %@", [keyValueChangeNewKey stringValue]]];
                    
                } else {
                    
                    [self bark:@"changed to indeterminate value"];
                    
                }
                
            } else {
                
                [self bark:@"is nil"];
                
            }
            
            break;
            
        case kDog:
            
            if (keyValueChangeNewKey && keyValueChangeNewKey.class && keyValueChangeNewKey.class != NSNull.class) {
                
                
                if ([keyValueChangeNewKey isKindOfClass:[NSNumber class]]) {
                    
                    if ([keyValueChangeNewKey respondsToSelector:@selector(stringValue)]) {
                        [self bark:[NSString stringWithFormat:@"changed value: %@", [keyValueChangeNewKey stringValue]]];
                    } else {
                        [self bark:@"changed NSNumber"];
                    }
                    
                } else if ([keyValueChangeNewKey isKindOfClass:[NSValue class]]) {
                    
                    if ((strcmp(@encode(CGRect), [keyValueChangeNewKey objCType]) == 0) &&
                        [keyValueChangeNewKey respondsToSelector:@selector(CGRectValue)]) {
                        [self bark:[NSString stringWithFormat:@"changed rect: %@", NSStringFromCGRect([keyValueChangeNewKey CGRectValue])]];
                    } else if ((strcmp(@encode(CGSize), [keyValueChangeNewKey objCType]) == 0) &&
                               [keyValueChangeNewKey respondsToSelector:@selector(CGSizeValue)]) {
                        [self bark:[NSString stringWithFormat:@"changed size: %@", NSStringFromCGSize([keyValueChangeNewKey CGSizeValue])]];
                    } else if ((strcmp(@encode(CGPoint), [keyValueChangeNewKey objCType]) == 0) &&
                               [keyValueChangeNewKey respondsToSelector:@selector(CGPointValue)]) {
                        [self bark:[NSString stringWithFormat:@"changed point: %@", NSStringFromCGPoint([keyValueChangeNewKey CGPointValue])]];
                    } else {
                        [self bark:@"changed NSValue"];
                    }
                    
                } else if ([keyValueChangeNewKey respondsToSelector:@selector(description)]) {
                    
                    [self bark:[NSString stringWithFormat:@"changed to: %@", [keyValueChangeNewKey description]]];
                    
                } else {
                    
                    [self bark:@"changed to indeterminate value"];
                    
                }
                
                
            } else {
                
                [self bark:@"is nil"];
                
            }
            
        case kDeadDog:
        default:
            break;
	}
    
}

- (void)bark:(NSString *)message
{
	if (_dogType != kDeadDog && _muzzled == NO) {
        
		NSLog(@"Bark! %@.%@ %@", [self.objectObserved class], self.keypath, message);
		if (self.disableBreakpointOnBark == NO) kill(getpid(), SIGSTOP);
        
	}
}

- (void)detatchDog
{
	if (self.objectObserved && _keypath) {
		[self stopObserving];
		[self setObjectObserved:nil];
	}
    
	_dogType = kDeadDog;
}

- (void)dealloc
{
	if (_dogType != kDeadDog) {
		if (_barkWhenObjectIsDeallocated) {
			NSLog(@"Bark! %@ %@", [self.objectObserved class], @"deallocated");
		}
		if (_disableBreakpointOnDealloc == NO) {
			kill(getpid(), SIGSTOP);
		}
		[self detatchDog];
	}
}

@end


/* /////////////////////////////// NSObject Category for NSDog /////////////////////////////////////// */

@implementation NSObject (NSDogCategory)

- (BOOL)addObserver:(id)observer forKeyPath:(NSString *)keyPath callback:(SEL)callback
{
	Dog *dog = [Dog callbackDogForObject:self keypath:keyPath observer:observer callback:callback];
	return (dog != nil);
}

- (BOOL)addObserver:(__weak id)weakObserver forKeyPath:(NSString *)keyPath block:(void (^)(void))changeBlock
{
	Dog *dog = [Dog blockDogForObject:self keypath:keyPath changeBlock:changeBlock];
	return (dog != nil);
}

- (BOOL)bindKeypath:(NSString *)keypath toBlock:(void (^)(void))executionBlock
{
	Dog *dog = [Dog blockDogForObject:self keypath:keypath changeBlock:executionBlock];
    dog.barkWhenObjectIsDeallocated = NO;
    dog.disableBreakpointOnBark = YES;
    dog.disableBreakpointOnDealloc = YES;
    dog.muzzled = YES;
    
	return (dog != nil);
}

- (BOOL)bindToTargetObject:(id)targetObject
             targetKeypath:(NSString *)targetKeypath
                 toKeypath:(NSString *)keypath
             bidirectional:(BOOL)bidirectional
{
	if ([self respondsToSelector:NSSelectorFromString(keypath)] == NO) {
		NSLog(@"Cannot bind object keypath not recognized");
		return NO;
	}
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	if ([targetObject respondsToSelector:NSSelectorFromString(targetKeypath)] == NO) {
		NSLog(@"Cannot bind target object keypath not recognized");
		return NO;
	}
#pragma clang diagnostic pop
    
	__unsafe_unretained typeof(self) weakSelf = self;
	__unsafe_unretained typeof(self) weakTarget = targetObject;
    
	Dog *dogTarget = [Dog blockDogForObject:targetObject keypath:targetKeypath changeBlock: ^{
        
        Dog *dogToMuzzle = [Dog muzzleDogAttachedToObject:self keypath:keypath];
        if (dogToMuzzle) {
            [weakSelf setValue:[targetObject valueForKey:targetKeypath] forKey:keypath];
            [dogToMuzzle beginObserving];
        }
        
    }];
    
	if (dogTarget && bidirectional == NO) {
		return YES;
	}
    
	Dog *dogSelf = nil;
    
	if (dogTarget && bidirectional) {
        
		dogSelf = [Dog blockDogForObject:self keypath:keypath changeBlock: ^{
            
            Dog *dogToMuzzle = [Dog muzzleDogAttachedToObject:weakTarget keypath:targetKeypath];
            if (dogToMuzzle) {
                [weakTarget setValue:[weakSelf valueForKey:keypath] forKey:targetKeypath];
                [dogToMuzzle beginObserving];
            }
            
        }];
        
	}
    
	return (dogSelf != nil);
}

@end
