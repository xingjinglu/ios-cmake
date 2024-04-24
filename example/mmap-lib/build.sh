#cmake -B build -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake -DPLATFORM=OS64 -DENABLE_BITCODE=1
rm -r build
#cmake -B build -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake -DPLATFORM=OS64COMBINED -DENABLE_BITCODE=1 -DARCHS="x86_64"
#cmake -B build -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake -DPLATFORM=OS64COMBINED -DENABLE_BITCODE=1
cmake -B build -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake -DPLATFORM=OS64 -DENABLE_BITCODE=1
cmake --build build --config Release
cmake --install build --config Release


