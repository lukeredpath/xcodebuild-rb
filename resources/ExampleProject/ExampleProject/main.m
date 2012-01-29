//
//  main.m
//  ExampleProject
//
//  Created by Luke Redpath on 28/01/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
#ifdef ALWAYS_FAIL
  puts("Holy missing semi-colon Batman!")
#endif
  
  @autoreleasepool {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
