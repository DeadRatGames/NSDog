//
//  ViewController.m
//  NSDog
//
//  Created by Christopher Larsen on 2013-03-12.
//  Copyright (c) 2013 DeadRatGames. All rights reserved.

#import "ViewController.h"

#import "Kitten.h"
#import "NSDog.h"

@interface ViewController ()

@property (nonatomic, strong) Kitten* badKitty;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageViewGrumpyCat.alpha = 0;
    
    _badKitty = [[Kitten alloc] init];

    
    NSDog(_badKitty, nil);
    
    
    // Two more Dog's you can try
    // [Dog watchDogForObject: _badKitty keypath: @"claws" relayObservedChangesTo: self];
    // [Dog guardDogForObject: _badKitty keypath: @"paws" lowerLimit: 1 upperLimit: 2];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    NSLog(@"ViewController has observed a change for %@!", [object class]);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _badKitty.paws = 2;
    _badKitty.paws = 3;
    _badKitty.claws = nil;
    _badKitty.behavingBadly = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _badKitty = nil; // Oh no!

    // If we didn't crash by this point ... success!
    //[UIView animateWithDuration: 3.0 animations:^{ _imageViewGrumpyCat.alpha = 1.0; }];
}

@end
