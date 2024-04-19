#pragma once

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <iostream>

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


template<typename T>
class MmapStorage{
  public:
    MmapStorage(){
      mData_ = nullptr;
      mSize_ = 0;
    }

    // 
    ~MmapStorage(){
      if(mData_ != nullptr){
        munmap(mData_, mSize_ * sizeof(T));
        mData_ = nullptr;
        mSize_ = 0;
      }

    }

    // size: number of element.
    int alloc(int size)
    {
      mData_ =static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_SHARED|MAP_ANONYMOUS, -1, 0));

      if(mData_ == MAP_FAILED){
        std::cerr<<"Failed to mmap" <<std::endl;
        return -1;
      }
      mSize_ = size;

      return 0;
    }

    // size: number of element.
    int alloc(int size, int fd)
    {
      ftruncate(fd, size * sizeof(T));
      mData_ =static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_SHARED, fd, 0));

      if(mData_ == MAP_FAILED){
        std::cerr<<"Failed to mmap" <<std::endl;
        return -1;
      }
      mSize_ = size;

      return 0;
    }

    // size: number of element.
    MmapStorage(int size)
    {
      mData_ =static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_PRIVATE|MAP_ANONYMOUS, -1, 0));

      if(mData_ == MAP_FAILED){
        std::cerr<<"Failed to mmap" <<std::endl;
        return;
      }
      mSize_ = size;
    }

    // return number of element.
    inline int size() const {
      return mSize_;
    }

    T *get()const{
      return mData_;
    }

    // 
    int set(T* data, int size)
    {
      if(nullptr != mData_ && mData_ != data){
        int ret = munmap(mData_, mSize_);
        if(ret != 0){
          std::cerr<<"Failed to munmap" << std::endl;
          return -1;
        }
      }

      // malloc memory space. TBD.
      mData_ = static_cast<T*>(mmap(NULL, size * sizeof(T), PROT_WRITE|PROT_READ, 
            MAP_PRIVATE|MAP_ANONYMOUS, -1, 0));

      if(mData_ == MAP_FAILED){
        std::cerr<<"Failed to mmap" <<std::endl;
        return -1;
      }
      mSize_ = size;

      return 0;
    }

    // 
    int reset(int size)
    {
      if(mData_ != nullptr)
        munmap(mData_, mSize_ * sizeof(T));

      set(mData_, size);

      return 0;
    }

    int release()
    {
      if(mData_ != nullptr) {
        if(0 != munmap(mData_, mSize_ * sizeof(T))){
          std::cerr<<"nunmap failed" << std::endl;
          return -1;
        }

        mData_ = nullptr;
        mSize_ = 0;
      }
      return 0;
    }



  private:
    T *mData_ = nullptr;
    // number of element with type T.
    int mSize_ = 0; 

};

// Mmap aligned with 4KB default.
// size: number of bytes.
// alignment: default value is 64bit.
void *MmapAllocAlign(size_t size, size_t alignment=8);
int MmapFree(void *m);





