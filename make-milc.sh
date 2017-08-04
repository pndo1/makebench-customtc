#!/bin/bash
cd $benchpath

if [[ ! -d milc-$cc$ccver-$libc ]]; then
  benchfile=$(ls $benchpath/*.tar.gz | grep -i milc)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder milc-$cc$ccver-$libc
  cd milc-$cc$ccver-$libc
else
  rm -r milc-$cc$ccver-$libc
  benchfile=$(ls $benchpath/*.tar.gz | grep -i milc)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder milc-$cc$ccver-$libc
  cd milc-$cc$ccver-$libc
fi
echo $LD64SO
cd libraries
sed -i "30s|.*|CC = $TOOLDIR/bin/$TOOLCHAIN-$cc|" Make_vanilla
sed -i '39iLD_LIBRARY_PATH=""' Make_vanilla
sed -i "36s|.*|OPT              = -static -O3 -opt-prefetch|" Make_vanilla
#--dynamic-linker=$LD64SO,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/lib64,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/usr/lib/|
cd ../ks_imp_rhmc
sed -i "48s|.*|OPT              = -static -g -O3 -lm -lgomp -fopenmp -Wl,-L$toollibs/,-L$MPICHPATH/mpich-$cc$ccver-$libc/lib|" Makefile
#-Wl,--dynamic-linker=$LD64SO,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/lib64,-rpath,$TOOLDIR/$TOOLCHAIN/sysroot/usr/lib/,-rpath,$MPICHPATH/mpich-$cc$ccver-$libc/lib
sed -i "38s|.*|CC = /soft/compilers/experimental/mpich-3.2/mpich-$cc$ccver-$libc/bin/mpicc|" Makefile
sed -i "40s|.*|CC = /soft/compilers/experimental/mpich-3.2/mpich-$cc$ccver-$libc/bin/mpicc|" Makefile
sed -i "124iMPdir        = $MPICHPATH/mpich-$cc$ccver-$libc/" Makefile
sed -i '125iIMPI        = -I$(MPdir)/include' Makefile
sed -i '126iMPlib        = $(Mpdir)/lib/libmpi.a' Makefile
sed -i '128iLMPI = -L/$(MPdir)/lib/shared -L/$(MPdir)/lib -lmpich' Makefile
sed -i 's|qopenmp|fopenmp|' Makefile

echo "milc-$cc$ccver-$libc has been configured"
echo "Begin compilation!"
cd ..
./build.sh
echo "Finished with milc!"
echo "Path to spec:"
echo "$benchpath/milc-$cc$ccver-$libc/"
status=2
