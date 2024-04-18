cmake -B build -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake -DPLATFORM=OS64 -DENABLE_BITCODE=1
cmake --build build --config Release


