//
//  ViewController.m
//  NSDog
//
//  Created by Christopher Larsen, Brian Croom on 2013-03-12.
//  Copyright (c) 2013 All rights reserved


#import "ViewController.h"
#import <objc/runtime.h>

#import "Kitten.h"
#import "NSDog.h"

@interface ViewController ()

@property (nonatomic, strong) Kitten* badKitty;

@end




@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.badKitty = [[Kitten alloc] init];
    
    
    /* Test a basic Dog just to observe dealloc */
    NSDog(_badKitty, nil);
    
    
    
    /* Test a basic Dog */
    NSDog(_badKitty, @"floatKitty");
    
    
    
    /* Test Watchdog that just relays KVO observations to some other object */
    [Dog watchDogForObject: _badKitty keypath: @"claws" relayObservedChangesTo: self];
    
    
    
    /* Test Guard Dog makes sure a variable stays within limits you set */
    [Dog guardDogForObject: _badKitty keypath: @"grumpiness" lowerLimit: -1.0 upperLimit: 0];
    
    
    
    /* Test Callback Dog that performs a selctor whenever the keypath changes */
    [_badKitty addObserver:self forKeyPath:@"behavingBadly" callback:@selector(callbackCheckKitty)];
    
    
    
    /* Test Block Dog that executes a block whenever the keypath changes */
    __weak typeof(self) weakSelf = self;
    [_badKitty addObserver: weakSelf forKeyPath:@"name" block:^{
       NSLog(@"Bad kitty has a name: %@", weakSelf.badKitty.name);
    }];

    
    
    /* Test the concrete types */
    NSDog(_badKitty, @"rectKitty");
    NSDog(_badKitty, @"pointKitty");
    NSDog(_badKitty, @"sizeKitty");
    NSDog(_badKitty, @"numberGrumpiness");
    NSDog(_badKitty, @"valueGrumpiness");

}

// The standard KVO Override
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    NSLog(@"ViewController has observed a change for %@ %@ %@", [object class], keyPath, [change objectForKey:NSKeyValueChangeNewKey]);
    
}

- (void)callbackCheckKitty
{
    NSLog(@"Kitty is %@", _badKitty.behavingBadly ? @"behaving badly." : @"being good." );
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // OK Kitty, go do stuff!
    
    _badKitty.behavingBadly = YES;
    _badKitty.name          = @"Grumpy Cat";
    _badKitty.claws         = [[NSObject alloc] init];
    _badKitty.claws         = nil;
    _badKitty.floatKitty    = 1.0;
    _badKitty.grumpiness    = -1.0;
    _badKitty.grumpiness    =  1.0;
    _badKitty.rectKitty     = CGRectZero;
    _badKitty.sizeKitty     = CGSizeZero;
    _badKitty.pointKitty       = CGPointZero;
    _badKitty.numberGrumpiness = [NSNumber numberWithInt:4];
    _badKitty.numberGrumpiness = [NSNumber numberWithFloat: 0.5];
    _badKitty.valueGrumpiness  = [NSValue valueWithCGRect:CGRectZero];
    _badKitty.valueGrumpiness  = [NSValue valueWithCGSize:CGSizeZero];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _badKitty = nil; // Oh no!

    // If we haven't crashed by this point ... SUCCESS!
    [UIView animateWithDuration: 4.0 animations:^{ self.imageViewGrumpyCat.alpha = 1.0; }];
}

@end
