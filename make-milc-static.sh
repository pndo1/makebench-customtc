#!/bin/bash
cd $benchpath

if [[ ! -d milc-$cc$ccver-$libc ]]; then
  benchfile=$(ls $benchpath/*.tar.gz | grep -i milc)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder milc-$cc$ccver-$libc-static
  cd milc-$cc$ccver-$libc-static
else
  rm -r milc-$cc$ccver-$libc
  benchfile=$(ls $benchpath/*.tar.gz | grep -i milc)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder milc-$cc$ccver-$libc-static
  cd milc-$cc$ccver-$libc-static
fi
echo $LD64SO
cd libraries
sed -i "30s|.*|CC = $TOOLDIR/bin/$TOOLCHAIN-$cc|" Make_vanilla
sed -i "39iLD_LIBRARY_PATH="$TOOLDIR/$TOOLCHAIN/sysroot/usr/lib/ $TOOLDIR/$TOOLCHAIN/sysroot/lib64/"" Make_vanilla
sed -i "36s|.*|OPT              = -static -O3 -opt-prefetch|" Make_vanilla
#--dynamic-linker=$LD64SO,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/lib64,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/usr/lib/|
cd ../ks_imp_rhmc
sed -i "48s|.*|OPT              = -static -g -O3 -Wl,-Bstatic,-lm -Wl,-Bstatic,-lgomp -fopenmp -Wl,-Bstatic,-L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/,-Bstatic,-L$TOOLDIR/$TOOLCHAIN/sysroot/usr/lib/,-Bstatic,-L$MPICHPATH/mpich-$cc$ccver-$libc/lib|" Makefile
#-Wl,-L$toollibs/,-L$MPICHPATH/mpich-$cc$ccver-$libc/lib,--dynamic-linker=$LD64SO,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/lib64,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/usr/lib/,-rpath,$MPICHPATH/mpich-$cc$ccver-$libc/lib
sed -i "49iOCFLAGS = -tpp2 -static" Makefile
sed -i "38s|.*|CC = /soft/compilers/experimental/mpich-3.2/mpich-$cc$ccver-$libc/bin/mpicc|" Makefile
sed -i "40s|.*|CC = /soft/compilers/experimental/mpich-3.2/mpich-$cc$ccver-$libc/bin/mpicc|" Makefile
sed -i "124iMPdir        = $MPICHPATH/mpich-$cc$ccver-$libc" Makefile
sed -i '125iIMPI        = -I$(MPdir)/include' Makefile
sed -i '126iMPlib        = $(Mpdir)/lib/libmpi.a' Makefile
sed -i '128iLMPI = -Wl,-Bstatic,-L/$(MPdir)/lib/shared -Wl,-Bstatic,-L/$(MPdir)/lib' Makefile
sed -i 's|qopenmp|fopenmp|' Makefile
sed -i 's|LDFLAGS = -fopenmp|LDFLAGS = -static -fopenmp|g' Makefile

echo "milc-$cc$ccver-$libc-static has been configured"
echo "Begin compilation!"
cd ..
./build.sh
echo "Finished with milc!"
echo "Path to spec:"
echo "$benchpath/milc-$cc$ccver-$libc-static/"
status=2
