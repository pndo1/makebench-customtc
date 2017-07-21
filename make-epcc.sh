#!/bin/bash
cd $benchpath

if [[ ! -d EPCC-OpenMP-$cc-$ccver-$libc ]]; then
  benchfile=$(ls $benchpath/*.tar.gz | grep openmp)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e 's/.tar.gz$//')
  mv $benchfolder EPCC-OpenMP-$cc-$ccver-$libc
  cd EPCC-OpenMP-$cc-$ccver-$libc
else
  rm -r EPCC-OpenMP-$cc-$ccver-$libc
  benchfile=$(ls $benchpath/*.tar.gz | grep openmp)
  tar -xf $benchfile
  benchfolder=$(echo $benchfile | sed -e "s/$.tar.gz//")
  mv $benchfolder EPCC-OpenMP-$cc-$ccver-$libc
  cd EPCC-OpenMP-$cc-$ccver-$libc
fi

if [ -e "Makefile.defs" ]
 then
   mv Makefile.defs Makefile.defs.$(date -I).$(date +%k%M)
   touch Makefile.defs
 else
   touch Makefile.defs
 fi

if [[ "$libc" == "musl" ]]; then
  LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/ | grep ld)
else
  LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/*.so | grep ld)
fi
echo $LD64SO
echo "OMPFLAG = -fopenmp -DOMPVER2 -DOMPVER3" >> Makefile.defs
echo "TOOLCHAIN=$TOOLCHAIN" >> Makefile.defs
echo "TOOLDIR=$TOOLDIR" >> Makefile.defs
echo "LD64SO=$LD64SO" >> Makefile.defs
echo "CC=$TOOLDIR/bin/$TOOLCHAIN-$cc" >> Makefile.defs
echo "LD=$TOOLDIR/bin/$TOOLCHAIN-ld" >> Makefile.defs
echo 'CFLAGS =  -O1 -lm' >> Makefile.defs
echo "LDFLAGS = -O0 -lm -lgomp -Wl,--dynamic-linker=$LD64SO" >> Makefile.defs
echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> Makefile.defs
echo 'LIBS =' >> Makefile.defs

echo "Makefile.defs has been configured"
echo "Begin compilation!"
make
status=2
