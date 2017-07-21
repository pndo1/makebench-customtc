#!/bin/bash
cd $benchpath

if [[ ! -d build-miniFE-$cc$ccver-$libc ]]; then
  benchfile=$(ls $benchpath/*.tar.gz | grep -i minife)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder build-miniFE-$cc$ccver-$libc
  cd build-miniFE-$cc$ccver-$libc/src
else
  rm -r build-miniFE-$cc$ccver-$libc
  benchfile=$(ls $benchpath/*.tar.gz | grep -i minife)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder build-miniFE-$cc$ccver-$libc
  cd build-miniFE-$cc$ccver-$libc/src
fi

if [ -e "Makefile-$cc$ccver-$libc" ]
 then
   mv Makefile-$cc$ccver-$libc Makefile-$cc$ccver-$libc.$(date -I).$(date +%k%M)
   touch Makefile-$cc$ccver-$libc
 else
   touch Makefile-$cc$ccver-$libc
 fi

echo $LD64SO
echo -e 'MINIFE_TYPES =  \' >> Makefile-$cc$ccver-$libc
echo -e '        -DMINIFE_SCALAR=double   \' >> Makefile-$cc$ccver-$libc
echo -e '        -DMINIFE_LOCAL_ORDINAL=int      \' >> Makefile-$cc$ccver-$libc
echo -e '        -DMINIFE_GLOBAL_ORDINAL="long long int"' >> Makefile-$cc$ccver-$libc
echo -e '' >> Makefile-$cc$ccver-$libc
echo -e 'MINIFE_MATRIX_TYPE = -DMINIFE_CSR_MATRIX' >> Makefile-$cc$ccver-$libc
echo 'CFLAGS = -O3 -fopenmp -lm '-L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ >> Makefile-$cc$ccver-$libc
echo 'CXXFLAGS = -O3 -fopenmp -lm '-L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ >> Makefile-$cc$ccver-$libc
echo 'CPPFLAGS = -I. -I../utils -I../fem $(MINIFE_TYPES) $(MINIFE_MATRIX_TYPE)' >> Makefile-$cc$ccver-$libc
echo "LDFLAGS = -lm -lgomp -L$TOOLDIR/$TOOLCHAIN/sysroot/lib64/ -Wl,--dynamic-linker=$LD64SO,-rpath,"$TOOLDIR"/"$TOOLCHAIN"/sysroot/lib64/" >> Makefile-$cc$ccver-$libc
echo "TOOLCHAIN=$TOOLCHAIN" >> Makefile-$cc$ccver-$libc
echo "TOOLDIR=$TOOLDIR" >> Makefile-$cc$ccver-$libc
echo "LD64SO=$LD64SO" >> Makefile-$cc$ccver-$libc
echo "CC=$TOOLDIR/bin/$TOOLCHAIN-$cc" >> Makefile-$cc$ccver-$libc
echo "LD=$TOOLDIR/bin/$TOOLCHAIN-ld" >> Makefile-$cc$ccver-$libc
echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> Makefile-$cc$ccver-$libc
echo "CXX=$TOOLDIR/bin/$TOOLCHAIN-g++" >> Makefile-$cc$ccver-$libc
echo 'LIBS =' >> Makefile-$cc$ccver-$libc
echo "include make_targets" >> Makefile-$cc$ccver-$libc
echo "Makefile-$cc$ccver-$libc has been configured"
echo "Begin compilation!"
make -f Makefile-$cc$ccver-$libc
status=2
