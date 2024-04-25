#pragma once

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <iostream>
#include <fstream>
#include <errno.h>

#define NDEBUG
#include <cassert>


#if defined(__clang__)
#define SHARED_EXPORT __attribute__((visibility("default")))
#define SHARED_LOCAL __attribute__((visibility("hidden")))
#endif

#if defined(IS_BUILDING_SHARED)
#define API SHARED_EXPORT
#else
#define API
#endif

#define MNN_MMAP_IOS


std::string createFile(std::string fileName, size_t size);
void* openAndTruncFile(std::string filePath, size_t size);

template<typename T>
class MmapStorage{
  public:
    MmapStorage(){
      mData_ = nullptr;
      mSize_ = 0;
      mFd_ = -2;
    }

    // 
    ~MmapStorage(){
      if(mData_ != nullptr){
        std::cout<<"MmapStorage::release size = " << mSize_ * sizeof(T) << std::endl;
        munmap(mData_, mSize_ * sizeof(T));
        if(mFd_ != -2 && mFd_ != -1){
          close(mFd_);
          mFd_ = -2;
        }
        if(mFilePath_ != ""){
          mFilePath_ = "";
        }

        mData_ = nullptr;
        mSize_ = 0;
      }
    
    }

    // size: number of element.
    int alloc(size_t size, int fd)
    {
      ftruncate(fd, size * sizeof(T));
      mData_ =static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_SHARED, fd, 0));

      if(mData_ == MAP_FAILED){
        printf("%s:%s:%d: Error, failed to mmap %s\n", __FILE__, __FUNCTION__, __LINE__, strerror(errno));
        return -1;
      }
      mSize_ = size;
      mFd_ = fd;

      return 0;
    }

    // Allocate mmap meomry with implicit file.
    int alloc(size_t  size, std::string file_name="example.txt")
    {
#ifdef MNN_MMAP_IOS
      //NSFileHandle *ptr = nil;
      std::string filePath = createFile(file_name, size * sizeof(T));
      if(filePath == "")
        printf("%s:%d:%s: Error, failed to createFile, %s\n", __FILE__, __LINE__, __FUNCTION__, strerror(errno));
      mData_ = static_cast<T*>(openAndTruncFile(filePath, size * sizeof(T)));
      if(mData_ == nullptr)
        return -1;
#endif

#if 0
      mData_ =static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_SHARED, fd, 0));

      if(mData_ == MAP_FAILED){
        printf("%s:%d:%s: Error, failed to mmap, %s\n", __FILE__, __LINE__, __FUNCTION__, strerror(errno));
        return -1;
      }
#endif

      std::cout<<"MmapStorage: size = " << size * sizeof(T) << std::endl;
      //close(mFd_);
      mSize_ = size;
#ifdef MNN_MMAP_IOS
      mFilePath_ = filePath;
#endif

      return 0;
    }



    // size: number of element.
    MmapStorage(size_t size, std::string file_name="test.txt")
    {
#ifdef MNN_MMAP_IOS
      std::string filePath = createFile(file_name, size * sizeof(T));
      mData_ = static_cast<T*>(openAndTruncFile(filePath, size * sizeof(T)));
#endif
#if 0 
      mData_ =static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_SHARED, mFd_, 0));

      if(mData_ == MAP_FAILED){
        printf("%s:%s:%d: Error, failed to mmap\n", __FILE__, __FUNCTION__, __LINE__);
        return;
      }
#endif
      std::cout<<"MmapStorage: size = " << size << std::endl;
      //close(mFd_);
      mFd_ = 0;
      mSize_ = size;
#ifdef MNN_MMAP_IOS
      mFilePath_ = filePath;
#endif
    }

    // return number of element.
    inline size_t size() const {
      return mSize_;
    }

    T *get()const{
      return mData_;
    }

    //  TBD
    int set(T* data, size_t size)
    {
      if(nullptr != mData_ && mData_ != data){
        int ret = munmap(mData_, mSize_);
        if(ret != 0){
          std::cerr<<"Failed to munmap" << std::endl;
          return -1;
        }
      }

      mData_ = data;
      mSize_ = size;

      return 0;
    }

    // 
    int reset(size_t size)
    {
      if(size == mSize_)
        return 0;

      // free mmap memory.
      if(mData_ != nullptr){
        if(0 != munmap(mData_, mSize_ * sizeof(T))){
          printf("%s:%s:%d; munmap failed\n", __FILE__, __FUNCTION__, __LINE__);
          return -1;
        }
        mData_ = nullptr;
        mSize_ = 0;
        mFd_ = -2;
      }


      return alloc(size);
    }

    int release()
    {
      if(mData_ != nullptr) {
        if(0 != munmap(mData_, mSize_ * sizeof(T))){
          printf("%s:%s:%d; munmap failed\n", __FILE__, __FUNCTION__, __LINE__);
          return -1;
        }
        if(mFd_ != 0) close(mFd_);
        if(mFilePath_ != ""){
          mFilePath_ = "";
          ;
        }
        mData_ = nullptr;
        mSize_ = 0;
      }
      return 0;
    }



  private:
    T *mData_ = nullptr;
    // number of element with type T.
    size_t mSize_ = 0; 
    int mFd_ = 0; // not used
    std::string mFilePath_ = ""; // not used

};

// reduant with AutoStorage.
class BufferStorageMmap{

  public:
    BufferStorageMmap(){
      storage = nullptr;
      allocated_size = 0;
      offset = 0;
    }

    // size: byte number.
    BufferStorageMmap(size_t size, size_t in_offset=0, std::string file_name="test.txt"){
#ifdef MNN_MMAP_IOS
      std::string filePath = createFile(file_name, size + in_offset);
      storage = static_cast<uint8_t*>(openAndTruncFile(filePath, size + in_offset));
#endif
#if 0
      storage =(uint8_t*)(mmap(NULL, size + in_offset, PROT_WRITE|PROT_READ, 
            MAP_PRIVATE|MAP_ANONYMOUS, -1, 0));

      if(storage == MAP_FAILED){
        std::cerr<<"Failed to mmap" <<std::endl;
        return;
      }
#endif
      if(storage == nullptr){
        return;
      }
      std::cout<<"MmapStorage: size = " << size << std::endl;
      allocated_size = size + in_offset;
      offset = in_offset;
    }

    ~BufferStorageMmap(){
      if(storage != nullptr){
        munmap(storage, (allocated_size + offset));

        if(file_path != ""){
          if(remove(file_path.c_str()) != 0)
          //  MNN_PRINT("%s:%s:%d: Error, remove file failed\n", __FILE__, __FUNCTION__, __LINE__);

          //file_path = "";
          ;
        }


        storage = nullptr;
        offset = 0;
        allocated_size = 0;
      }
    }

    //
    size_t size() const{
      return allocated_size - offset;
    } 
    const uint8_t *buffer()const{
      return storage + offset;
    } 


    int alloc(size_t size, size_t in_offset = 0, std::string file_name = "test.txt")
    {

#ifdef MNN_MMAP_IOS
      std::string filePath = createFile(file_name, size + in_offset);
      storage = static_cast<uint8_t*>(openAndTruncFile(filePath, size + in_offset));
#endif
#if 0
      int fd = open(filePath.c_str(), O_RDWR);
      ftruncate(fd, size + in_offset);
      storage =static_cast<uint8_t*>(mmap(NULL, size + in_offset, PROT_WRITE|PROT_READ, 
            MAP_SHARED, fd, 0));

      if(storage == MAP_FAILED){
        //MNN_PRINT("%s:%s:%d: Error, failed to mmap\n", __FILE__, __FUNCTION__, __LINE__);
        printf("%s:%s:%d: Error, failed to mmap\n", __FILE__, __FUNCTION__, __LINE__);
        return -1;
      }
#endif
      if(storage == nullptr){
        return -1;
      }

      std::cout<<"BufferStorage: size = " << (size + in_offset) << std::endl;
      close(fd);
      allocated_size = size + in_offset;
      file_path = filePath;

      return 0;
    }


    // size: user-can-use memory size.
    // allocated_size_ = size + offset.
    int set(uint8_t* data, size_t size, size_t in_offset=0)
    {
      if(nullptr != storage ){
        int ret = munmap(storage, allocated_size);
        if(ret != 0){
          std::cerr<<"Failed to munmap" << std::endl;
          return -1;
        }
      }

      // 
      storage = (uint8_t*)data;
      allocated_size = size + in_offset;
      offset = in_offset;

      return 0;
    }


   
    // allocated_size = size + offset.
    size_t offset = 0;
    size_t allocated_size = 0;
    uint8_t * storage = nullptr;
    std::string file_path = 0;
    int fd = 0;
};
