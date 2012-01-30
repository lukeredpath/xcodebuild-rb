//
//  ExampleProjectTests.m
//  ExampleProjectTests
//
//  Created by Luke Redpath on 28/01/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "ExampleProjectTests.h"

@implementation ExampleProjectTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSuccess
{
  STAssertEqualObjects(@"foo", @"foo", @"Objects didn't match");
}

- (void)testFailure
{
    STFail(@"Unit tests are not implemented yet in ExampleProjectTests");
}

@end
