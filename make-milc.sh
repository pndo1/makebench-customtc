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

cd libraries
sed -i 's/CC               = cc  # ( cc89 gcc xlc gcc pgcc cl g++ )/CC               = $TOOLDIR/bin/$TOOLCHAIN-$cc/g' Make_vanilla
sed -i 's/CC               = cc  # ( cc89 gcc xlc gcc pgcc cl g++ )/CC               = $TOOLDIR/bin/$TOOLCHAIN-$cc/g' Make_vanilla
sed -i '39iLD_LIBRARY_PATH=''' Make_vanilla
sed -i 's/OPT              = -O3 -xAVX -ip -opt-prefetch/OPT              = -O3 -opt-prefetch -Wl,--dynamic-linker=/soft/compilers/experimental/x-tools/gcc/7.1.0/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/lib64/ld-2.25.so,-rpath,/soft/compilers/experimental/x-tools/gcc/7.1.0/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/lib64,/g'
cd ../ks_imp_rhmc
awk "NR==36 {$0="OPT              = -g -O3 -lm -lgomp -fopenmp -Wl,--dynamic-linker=$LD64SO,-rpath,"$TOOLDIR"/"$TOOLCHAIN"/sysroot/lib64,-rpath,$MPICHPATH/mpich-$cc$ccver-$libc/lib,-L$toollibs/,-L$MPICHPATH/mpich-$cc$ccver-$libc/lib"} 1" Makefile
awk "NR==28 {$0="  CC = /soft/compilers/experimental/mpich-3.2/mpich-$cc$ccver-$libc/bin/mpicc"} 1" Makefile
awk "NR==30 {$0="  CC = /soft/compilers/experimental/mpich-3.2/mpich-$cc$ccver-$libc/bin/mpicc"} 1" Makefile
sed -i "88iMPdir        = $MPICHPATH/mpich-$cc$ccver-$libc/"
sed -i "89iIMPI        = -I$(MPdir)/include"
sed -i "90iMPlib        = $(Mpdir)/lib/libmpi.a"
sed -i "92iLMPI = -L/$(MPdir)/lib/shared -L/$(MPdir)/lib -lmpich"

# echo $LD64SO
# echo 'CFLAGS = -O3 -fopenmp -lm '-L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ >> Makefile-$cc$ccver-$libc
# echo 'CXXFLAGS = -O3 -fopenmp -lm '-L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ >> Makefile-$cc$ccver-$libc
# echo 'CPPFLAGS = -DHAVE_MPI -Dmilc_REPORT_RUSAGE -I. -I../utils -I../fem $(milc_TYPES) $(milc_MATRIX_TYPE)' -I$MPICHPATH/mpich-$cc$ccver-$libc/include >> Makefile-$cc$ccver-$libc
# echo "LDFLAGS = -O3 -fopenmp -lm -lgomp -Wl,--dynamic-linker=$LD64SO,-rpath,"$TOOLDIR"/"$TOOLCHAIN"/sysroot/lib64,-rpath,$MPICHPATH/mpich-$cc$ccver-$libc/lib,-L$toollibs/,-L$MPICHPATH/mpich-$cc$ccver-$libc/lib" >> Makefile-$cc$ccver-$libc
# echo "TOOLCHAIN=$TOOLCHAIN" >> Makefile-$cc$ccver-$libc
# echo "TOOLDIR=$TOOLDIR" >> Makefile-$cc$ccver-$libc
# echo "LD64SO=$LD64SO" >> Makefile-$cc$ccver-$libc
# echo "CC=$MPICHPATH/mpich-$cc$ccver-$libc/bin/mpicc" >> Makefile-$cc$ccver-$libc
# echo "LD=$TOOLDIR/bin/$TOOLCHAIN-ld" >> Makefile-$cc$ccver-$libc
# echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> Makefile-$cc$ccver-$libc
# echo "CXX=$MPICHPATH/mpich-$cc$ccver-$libc/bin/mpic++" >> Makefile-$cc$ccver-$libc
# echo 'LIBS =' >> Makefile-$cc$ccver-$libc
# echo "include make_targets" >> Makefile-$cc$ccver-$libc
# echo "Makefile-$cc$ccver-$libc has been configured"
# echo "Begin compilation!"
# make -f Makefile-$cc$ccver-$libc
# echo "Finished with milc!"
# echo "Path to spec:"
# echo "$benchpath/milc-$cc$ccver-$libc/src/"
# status=2
