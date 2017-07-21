#!/bin/bash
cd $benchpath

if [[ ! -d build-miniFE-$cc$ccver-$libc ]]; then
  benchfile=$(ls $benchpath/*.tar | grep -i minife)
  mkdir build-miniFE-$cc$ccver-$libc
  tar -xf $benchfile  -C build-miniFE-$cc$ccver-$libc
  cd build-miniFE-$cc$ccver-$libc/source
else
  rm -r build-miniFE-$cc$ccver-$libc
  benchfile=$(ls $benchpath/*.tar.gz | grep -i minife)
  mkdir build-miniFE-$cc$ccver-$libc
  tar -xf $benchfile -C build-miniFE-$cc$ccver-$libc
  cd build-miniFE-$cc$ccver-$libc/source
fi

if [ -e "makefile-$cc$ccver-$libc" ]
 then
   mv makefile-$cc$ccver-$libc makefile-$cc$ccver-$libc.$(date -I).$(date +%k%M)
   touch makefile-$cc$ccver-$libc
 else
   touch makefile-$cc$ccver-$libc
 fi

if [[ "$libc" == "musl" ]]; then
  LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/ | grep ld)
else
  LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/*.so | grep ld)
fi
echo $LD64SO
echo -e 'MINIFE_TYPES =  \' >> makefile-$cc$ccver-$libc
echo -e '        -DMINIFE_SCALAR=double   \' >> makefile-$cc$ccver-$libc
echo -e '        -DMINIFE_LOCAL_ORDINAL=int      \' >> makefile-$cc$ccver-$libc
echo -e '        -DMINIFE_GLOBAL_ORDINAL="long long int"' >> makefile-$cc$ccver-$libc
echo -e '' >> makefile-$cc$ccver-$libc
echo -e 'MINIFE_MATRIX_TYPE = -DMINIFE_CSR_MATRIX' >> makefile-$cc$ccver-$libc
echo 'CFLAGS = -O3 -mp -lm' >> makefile-$cc$ccver-$libc
echo 'CXXFLAGS = -O3 -mp -lm' >> makefile-$cc$ccver-$libc
echo 'CPPFLAGS = -I. -I../utils -I../fem $(MINIFE_TYPES) $(MINIFE_MATRIX_TYPE)' >> makefile-$cc$ccver-$libc
echo "LDFLAGS = -lm -lgomp -Wl,--dynamic-linker=$LD64SO,-rpath,"$TOOLDIR"/"$TOOLCHAIN"/sysroot/lib64/" >> makefile-$cc$ccver-$libc
echo "TOOLCHAIN=$TOOLCHAIN" >> makefile-$cc$ccver-$libc
echo "TOOLDIR=$TOOLDIR" >> makefile-$cc$ccver-$libc
echo "LD64SO=$LD64SO" >> makefile-$cc$ccver-$libc
echo "CC=$TOOLDIR/bin/$TOOLCHAIN-$cc" >> makefile-$cc$ccver-$libc
echo "LD=$TOOLDIR/bin/$TOOLCHAIN-ld" >> makefile-$cc$ccver-$libc
echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> makefile-$cc$ccver-$libc
echo "CXX=$TOOLDIR/bin/$TOOLCHAIN-g++" >> makefile-$cc$ccver-$libc
echo 'LIBS =' >> makefile-$cc$ccver-$libc
echo "include make_targets" >> makefile-$cc$ccver-$libc
echo "makefile-$cc$ccver-$libc has been configured"
echo "Begin compilation!"
make -f makefile-$cc$ccver-$libc
status=2
