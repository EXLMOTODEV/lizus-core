#!/bin/bash
cd "$(dirname "$0")"

pacman --noconfirm -S --needed mingw-w64-x86_64-toolchain
pacman --noconfirm -S --needed git
pacman --noconfirm -S --needed mingw-w64-x86_64-qt5-static
pacman --noconfirm -S --needed mingw-w64-x86_64-miniupnpc
pacman --noconfirm -S --needed mingw-w64-x86_64-qrencode
pacman --noconfirm -S --needed mingw-w64-x86_64-jasper
pacman --noconfirm -S --needed mingw-w64-x86_64-libevent
pacman --noconfirm -S --needed mingw-w64-x86_64-curl
wget http://esxi.z-lab.me:666/~exl_lab/software/msys2-packages.tar
tar -xf msys2-packages.tar
rm msys2-packages.tar
pacman --noconfirm -U packages/*.pkg.tar.xz

rm -Rf src/secp256k1
git clone https://github.com/bitcoin-core/secp256k1 --depth 1 -b master src/secp256k1
cd src/secp256k1
./autogen.sh
./configure --prefix=/usr/local --enable-module-recovery
make -j3
make install
cd ../../

sed -i "s/-Wl,--large-address-aware//g" lizus.pro
sed -i "s/BOOST_LIB_SUFFIX=-mgw49-mt-s-1_57/BOOST_LIB_SUFFIX=-mt/g" lizus.pro
sed -i "s/LIBS += -lboost_system-mgw49-mt-s-1_57 -lboost_filesystem-mgw49-mt-s-1_57 -lboost_program_options-mgw49-mt-s-1_57 -lboost_thread-mgw49-mt-s-1_57/LIBS += -lboost_system-mt -lboost_filesystem-mt -lboost_program_options-mt -lboost_thread-mt -lgmp/g" lizus.pro
sed -i "s/OS_WINDOWS_CROSSCOMPILE | NATIVE_WINDOWS)/OS_WINDOWS_CROSSCOMPILE | NATIVE_WINDOWS | MINGW64_NT-6.1 | MINGW32_NT-6.1 | MINGW32_NT-10.0 | MINGW64_NT-10.0 | MINGW32_NT-6.3 | MINGW64_NT-6.3)/g" src/leveldb/build_detect_platform
make -j4 -C src/leveldb/ libleveldb.a libmemenv.a
/mingw64/qt5-static/bin/qmake CONFIG+=release CONFIG+=static INCLUDEPATH+=/usr/local/include LIBS+='-static-libgcc -static-libstdc++ -L/usr/local/lib' lizus.pro
make -j4 -f Makefile.Release
strip -s release/lizus-qt.exe

curl -sS --upload-file release/lizus-qt.exe https://transfer.sh/lizus-qt.exe && echo -e '\n'
