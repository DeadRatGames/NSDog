NSDog
=====

 Still using NSLog?

 Why log something at a single point in time when you can make a **Dog** that will dynamically log object properties in real time! 

 Dogs use KVO Observation to track objects **throughout their lifetime** 

- Attach a Dog to any object and it will **bark** (a log message) when that object is deallocated.
- A Dog can watch any property of an object and **bark** (a log message) when it changes.

- #####NSDog is your best friend when it comes to debugging Objective C!

 - And it's as dead simple as this:

 `NSDog(myObject, @"frame");`

The Manual
==========

 Download the full-color PDF Manual for NSDog included in the archive.

  [NSDog Manual](https://github.com/xtreme-christopher-larsen/NSDog/blob/master/NSDog%20-%20The%20Manual.pdf)



Installation
============

1. To install NSDog in your project, all you need is this zip with the .h and .m: 
 
   [NSDog Includes.zip](https://github.com/xtreme-christopher-larsen/NSDog/blob/master/NSDog%20Includes.zip)

2. Read the Manual !   It's actually really really awesome. :)

3. Good luck have fun!

UPDATE
======

NSDog now gives you the ability to bind object in iOS like you do in OSX!

Dogs are perfect for binding, because you can bind two properties on two objects and not worry about crashing when one of them is deallocated with a KVO still attached.

Now you can bind one property to the same kind of property on another object, or execute a block whenever a property changes.

Functional Reactive Programming, the easy way!


- (BOOL)bindKeypath:(NSString*)keypath toBlock:(void(^)(void))executionBlock;

- (BOOL)bindToTargetObject:(id)objectTarget
             targetKeypath:(NSString*)targetKeypath
                 toKeypath:(NSString*)keypath
             bidirectional:(BOOL)bidirectional;
