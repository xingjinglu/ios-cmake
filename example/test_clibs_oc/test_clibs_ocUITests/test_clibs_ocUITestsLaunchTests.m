//
//  test_clibs_ocUITestsLaunchTests.m
//  test_clibs_ocUITests
//
//  Created by xingjing lu on 2024/4/18.
//

#import <XCTest/XCTest.h>

@interface test_clibs_ocUITestsLaunchTests : XCTestCase

@end

@implementation test_clibs_ocUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
