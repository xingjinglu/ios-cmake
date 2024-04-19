//
//  main.m
//  test_clibs_oc
//
//  Created by xingjing lu on 2024/4/18.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "HelloWorld.hpp"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    NSLog(@"Hello World2!");
    HelloWorld hw;
    NSLog(@"Hello World3!");
    std::string rtn = hw.helloWorld();
    NSString *nsStr = [NSString stringWithUTF8String:rtn.c_str()];
    NSLog(@"static library %@",nsStr);
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
