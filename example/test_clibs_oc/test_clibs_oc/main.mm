//
//  main.m
//  test_clibs_oc
//
//  Created by xingjing lu on 2024/4/18.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <fstream>
#include "HelloWorld.hpp"
#include "MmapUtilsIos.hpp"
#include <Foundation/Foundation.h>
#include "stdio.h"
#include "stdlib.h"
#include "unistd.h"
#include <cerrno>

bool truncateFile(const std::string& path, NSUInteger newSize) {
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[NSString stringWithUTF8String:path.c_str()]];
    if (fileHandle == nil) {
        NSLog(@"Error opening file");
        return NO;
    }
    [fileHandle truncateFileAtOffset:newSize];
    [fileHandle closeFile];
    return YES;
}

bool changePermissions(const std::string& path, NSUInteger permissions) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* nsPath = [NSString stringWithUTF8String:path.c_str()];
    NSDictionary* attributes = @{NSFilePosixPermissions: @(permissions)};
    NSError* error;
    BOOL success = [fileManager setAttributes:attributes ofItemAtPath:nsPath error:&error];
    if (!success) {
        NSLog(@"Error changing permissions: %@", error);
    }
    return success;
}

void printAttributes(const std::string& path) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* nsPath = [NSString stringWithUTF8String:path.c_str()];
    NSError* error;
    NSDictionary* attributes = [fileManager attributesOfItemAtPath:nsPath error:&error];
    if (attributes == nil) {
        NSLog(@"Error getting attributes: %@", error);
        return;
    }
    NSLog(@"Attributes: %@", attributes);
}

void listFiles(const std::string& directory) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    NSArray* files = [fileManager contentsOfDirectoryAtPath:[NSString stringWithUTF8String:directory.c_str()] error:&error];
    if (files == nil) {
        NSLog(@"Error listing files: %@", error);
    } else {
        for (NSString* file in files) {
            NSLog(@"%@", file);
        }
    }
}

void checkPermissions(const std::string& path) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* nsPath = [NSString stringWithUTF8String:path.c_str()];
    
    if ([fileManager isReadableFileAtPath:nsPath]) {
        NSLog(@"File is readable");
    }
    else
        NSLog(@"File is not readable");
    
    if ([fileManager isWritableFileAtPath:nsPath]) {
        NSLog(@"File is writable");
    }
    else
        NSLog(@"File is not writable");
    
    if ([fileManager isExecutableFileAtPath:nsPath]) {
        NSLog(@"File is executable");
    }
    else
        NSLog(@"File is not executable");
    
    if ([fileManager isDeletableFileAtPath:nsPath]) {
        NSLog(@"File is deletable");
    }
    else
        NSLog(@"File is not deletable");
    
    if([fileManager fileExistsAtPath:nsPath]){
        NSLog(@"File exist");
    }
    else
        NSLog(@"File not exist");
}

int check_file_error(int no, std::string msg="")
{
    switch(no){
        case EACCES:
            printf("EACCES %s \n",strerror(no));
            break;
        case EEXIST:
            printf("EEXIST %s \n",strerror(no));
            break;
        case ENOENT:
            printf("ENOENT %s \n",strerror(no));
            break;
        case EBADF:
            printf("EBDAF %s \n",strerror(no));
            break;
        case EROFS:
            printf("EROFS %s \n",strerror(no));
            break;
        case EFAULT:
            printf("EFAULT %s \n",strerror(no));
            break;
        case EINVAL:
            printf("EINVAL %s \n",strerror(no));
            break;
        case ENAMETOOLONG:
            printf("ENAMETOOLONG %s \n",strerror(no));
            break;
        case ENOTDIR:
            printf("ENOTDIR %s \n",strerror(no));
            break;
        case ENOMEM:
            printf("NOMEM %s \n",strerror(no));
            break;
        case ELOOP:
            printf("ELOOP %s \n",strerror(no));
            break;
        case EIO:
            printf("EIO %s %s \n",strerror(no), msg.c_str());
            break;
            
        case 0:
            printf("%s. %s\n",strerror(no), msg.c_str());
            break;
        default:
            printf("errno not found \n");
            break;
            
    }
    
    return 0;
}

void createFileWithPermissions(std::string &path, NSNumber *permissions) {
    NSString *filePath =[NSString stringWithUTF8String:path.c_str()];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSDictionary *attributes = @{NSFilePosixPermissions: permissions};
        BOOL success = [fileManager createFileAtPath:filePath contents:nil attributes:attributes];
        if (success) {
            NSLog(@"File created successfully");
        } else {
            NSLog(@"Error creating file");
        }
    } else {
        NSLog(@"File already exists");
    }
}


bool deleteFile(const std::string& path) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* nsPath = [NSString stringWithUTF8String:path.c_str()];
    NSError* error;
    BOOL success = [fileManager removeItemAtPath:nsPath error:&error];
    if (!success) {
        NSLog(@"Error deleting file: %@", error);
    }
    return success;
}

void updateFile(NSString *filePath, NSData *data) {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    if (fileHandle == nil) {
        NSLog(@"%s:%d: Error opening file",__FILE__, __LINE__);
        return;
    }
    else
        NSLog(@"%s:%d: succedd opening file",__FILE__, __LINE__);
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

int getFd(NSFileHandle* fileHandle)
{
    int fd = [fileHandle fileDescriptor];
    return fd;
}

int test_mmap()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    std::string docDirStr = [docDir UTF8String];
    //listFiles(docDirStr);
    
    std::string filePath = docDirStr + "/example.txt";
    NSString *nsFilePath= [NSString stringWithUTF8String:filePath.c_str()];
    
    errno = 0;
    printf("filePath = %s \n", filePath.c_str());
    printf("docDirStr = %s \n", docDirStr.c_str());
    
    // ios api
    //checkPermissions(filePath);
    //deleteFile(filePath);
    createFileWithPermissions(filePath, @420);
    
    size_t size =2 * 256*1024*1024;
    errno = 0;
    //printf("To open file: %s \n", filePath.c_str());
    NSString* nsPath = [NSString stringWithUTF8String:filePath.c_str()];
    
    
    // mmap2
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:nsPath];
    if (fileHandle == nil) {
        NSLog(@"Error opening file");
        check_file_error(errno);
    }
    int fd2 = [fileHandle fileDescriptor];
    
    // test with df.
    MmapStorage<int> m2;
    //m2.alloc(size, fd2);
    std::string fileName = "test.txt";
    m2.alloc(size, fileName);
    filePath = docDirStr + "/test.txt";
    truncateFile(filePath, size * sizeof(int));
    //listFiles(docDirStr);
    
    int *mptr2 = m2.get();
    std::cout<<"m_ptr2 = " << mptr2 << std::endl;
    printAttributes(filePath);
    //m2.release();
    //printAttributes(filePath);
    //deleteFile(filePath);
    
    // mmap3
#if 0
    filePath = docDirStr + "/example3.txt";
    NSString *filePathNs = [NSString stringWithUTF8String:filePath.c_str()];
    createFileWithPermissions(filePath, @420);
    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePathNs];
    if (fileHandle == nil) {
        NSLog(@"Error opening file");
        check_file_error(errno);
    }
    else
        NSLog(@"succeed opening file");
    int fd3 = [fileHandle fileDescriptor];
    [fileHandle closeFile];
#endif
    MmapStorage<int> m3;
    m3.alloc(size,"test.txt");
    int *mptr3 = m3.get();
    std::cout<<"m_ptr3 = " << mptr3 << std::endl;
    printAttributes(filePath);
    //printAttributes(filePath);
    
    
    
    MmapStorage<int> m6;
    m6.alloc(size,"test.txt");
    int *mptr6 = m6.get();
    std::cout<<"m_ptr6 = " << mptr6 << std::endl;
    
    MmapStorage<int> m7;
    m7.alloc(size,"test.txt");
    int *mptr7 = m7.get();
    std::cout<<"m_ptr7 = " << mptr7 << std::endl;
    
    // mmap-4
#if 0
    filePath = docDirStr + "/example3.txt";
    filePathNs = [NSString stringWithUTF8String:filePath.c_str()];
    
    createFileWithPermissions(filePath, @420);
    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePathNs];
    if (fileHandle == nil) {
        NSLog(@"Error opening file");
        check_file_error(errno);
    }
    else
        NSLog(@"succeed opening file");
    //int fd4 = [fileHandle fileDescriptor];
    
    int fd4 = getFd(fileHandle);
#endif
    
    MmapStorage<int> m4;
    //m4.alloc(size, fd4);
    m4.alloc(size, "test.txt");
    //[fileHandle closeFile];
    int *mptr4 = m4.get();
    std::cout<<"m_ptr4 = " << mptr4 << std::endl;
    printAttributes(filePath);
    
    // mmap5
#if 0
    filePath = docDirStr + "/example5.txt";
    filePathNs = [NSString stringWithUTF8String:filePath.c_str()];
    
    createFileWithPermissions(filePath, @420);
    truncateFile(filePath, sizeof(int) * size);
    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePathNs];
    if (fileHandle == nil) {
        NSLog(@"Error opening file");
        check_file_error(errno);
    }
    else
        NSLog(@"succeed opening file");
    int fd5 = [fileHandle fileDescriptor];
    [fileHandle closeFile];
#endif
    
    MmapStorage<int> m5;
    m5.alloc(size, "test.txt");
    int *mptr5 = m5.get();
    std::cout<<"m_ptr5 = " << mptr5 << std::endl;
    printAttributes(filePath);
    
    for(int i = 0; i < size; i++){
        mptr2[i] = i + 2;
        mptr3[i] = mptr2[i];
        mptr6[i] = mptr2[i];
        mptr7[i] = mptr2[i];
        mptr4[i] = mptr2[i];
        mptr5[i] = mptr2[i];
        
    }
    
    MmapStorage<int> m8, m9, m10, m11, m12, m13, m14;
    m8.alloc(size, "test.txt");
    m9.alloc(size, "test.txt");
    m10.alloc(size, "test.txt");
    m11.alloc(size, "test.txt");
    m12.alloc(size, "test.txt");
    m13.alloc(size, "test.txt");
    m14.alloc(size, "test.txt");
    int *mptr8 = m8.get();
    std::cout<<"m_ptr8 = " << mptr8 << std::endl;
    
    return 0;
}

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
    
    // test
    test_mmap();
    return 0;
    
    size_t size = 0.8 * 1024 * 256 * 1024;
    int *ptr = (int*) malloc(size * sizeof(int));
    for(size_t i = 0; i < size; i++)
        ptr[i] = i + 2;
    
#if 0
    @autoreleasepool {
        // Get the path to the Documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        // Create the path to the file
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"example8.txt"];
        std::string filePathStr = [filePath UTF8String];
        std::string dirStr = [documentsDirectory UTF8String];
        
        // Update the file with some data
        NSData *data = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
        createFileWithPermissions(filePathStr, @400);
        updateFile(filePath, data);
        printf("filePath = %s\n", filePathStr.c_str());
        listFiles(dirStr);
        printAttributes(filePathStr);
        deleteFile(filePathStr);
    }
    return 0;
    
#endif
    
#if 0
    //NSString *tmpDir = NSTemporaryDirectory();
    //std::string tmpDirStr = [tmpDir UTF8String];
    //listFiles(tmpDirStr);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString *examplePath = [NSString stringWithFormat:@"%@/example.txt",docDir];
    std::string filePath = [examplePath UTF8String];
    deleteFile(filePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:examplePath]) {
        [fileManager createFileAtPath:examplePath contents:nil attributes:nil];
    }
    
    printAttributes(filePath);
    printf("filePath = %s\n", filePath.c_str());
    
#endif
    
#if 0
    if(access(filePath.c_str(), F_OK) != -1){
        printf("F_OK \n");
        check_file_error(errno, "File not exist");
    }
    if(access(filePath.c_str(), R_OK) != -1){
        printf("R_OK \n");
        check_file_error(errno, "Have no read permission");
    }
    if(access(filePath.c_str(), W_OK) != -1){
        printf("W_OK \n");
        check_file_error(errno, "Have no write permission");
    }
    if(access(filePath.c_str(), X_OK) != -1){
        printf("X_OK \n");
        check_file_error(errno, "Have no execute/search permission");
    }
#endif
    
    //
    
    //NSString *tmpDir = NSTemporaryDirectory();
    //std::string tmpDirStr = [tmpDir UTF8String];
    
    
    // 查看文件权限
    
    
    //truncateFile(filePath, 1);
    //deleteFile(filePath);
    
    //printAttributes(filePath);
    //changePermissions(filePath, 666);
    //printAttributes(filePath);
    
    
    
#if 0
    std::ofstream file(filePath);
    if(file.is_open()){
        file << "test";
        file.close();
    }else
    {
        NSLog(@"failed open file example.txt");
    }
#endif
    
    
    
    
    
    
    
#if 0
    listFiles(tmpDirStr);
    filePath = tmpDirStr + "/example1.txt";
    nsFilePath= [NSString stringWithUTF8String:filePath.c_str()];
    createFileWithPermissions(filePath, @420);
    listFiles(tmpDirStr);
#endif
    //int fd3 = open(filePath.c_str(), O_RDWR);
    
    
#if 0
    m2.alloc(size, filePath);
    int *mptr2 = m2.get();
    //int *mptr2 = (int*)malloc(sizeof(int)* size);
    std::cout<<"m_ptr2 = " << mptr2 << std::endl;
    for(int i = 0; i < size; i++){
        mptr2[i] = i + 2;
    }
    
    MmapStorage<int> m3;
    m3.alloc(size, filePath);
    int *mptr3 = m3.get();
    std::cout<<"m_ptr3 = " << mptr3 << std::endl;
    
#endif
    
    NSLog(@"end of write memory");
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
