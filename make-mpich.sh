cd $benchpath

if [[ ! -d mpich-$cc$ccver-$libc ]]; then
  mkdir mpich-$cc$ccver-$libc
else
  rm -r mpich-$cc$ccver-$libc
  mkdir mpich-$cc$ccver-$libc
fi
if [[ ! -d build-mpich-$cc$ccver-$libc ]]; then
  mkdir build-mpich-$cc$ccver-$libc
  cd build-mpich-$cc$ccver-$libc
else
  rm -r build-mpich-$cc$ccver-$libc
  mkdir build-mpich-$cc$ccver-$libc
  cd build-mpich-$cc$ccver-$libc/src
fi



export CC=$TOOLDIR/bin/$TOOLCHAIN-$cc
export CFLAGS=-lm -L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/
export CXXFLAGS=-lm -L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/
export LDFLAGS=-lm -L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ -Wl,--dynamic-linker=$LD64SO,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/lib64
export LD=$TOOLDIR/bin/$TOOLCHAIN-ld
export CPP=$TOOLDIR/bin/$TOOLCHAIN-cpp
export CXX=$TOOLDIR/bin/$TOOLCHAIN-g++
export LIBS=
../configure LDFLAGS="-lm -L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ -Wl,--dynamic-linker=$LD64SO,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/lib64" CPP=$TOOLDIR/bin/$TOOLCHAIN-cpp CXX=$TOOLDIR/bin/$TOOLCHAIN-g++ LD=$TOOLDIR/bin/$TOOLCHAIN-ld CC=$TOOLDIR/bin/$TOOLCHAIN-$cc CFLAGS="-lm -L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/"   --prefix=$benchpath/mpich-$cc$ccver-$libc --exec-prefix=$benchpath/mpich-$cc$ccver-$libc --enable-shared --with-pm=hydra --with-pmi=yes --enable-romio --disable-f77 --disable-f90
make
