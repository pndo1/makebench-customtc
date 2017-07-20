#!/bin/bash
cd $benchpath
cd setup

if [ -e "Make.$cc$ccver-$libc" ]
 then
   mv Make.$cc$ccver-$libc Make.$cc$ccver-$libc.$(date -I).$(date +%k%M)
   touch Make.$cc$ccver-$libc
 else
   touch Make.$cc$ccver-$libc
 fi

echo $LD64SO
echo -e 'SHELL        = /bin/sh\nCD           = cd\n\nCP           = cp\nLN_S         = ln -s -f\nMKDIR        = mkdir -p\nRM           = /bin/rm -f\nTOUCH        = touch' >> Make.$cc$ccver-$libc
echo -e 'TOPdir       = .\nSRCdir       = $(TOPdir)/src\nINCdir       = $(TOPdir)/src\nBINdir       = $(TOPdir)/bin' >> Make.$cc$ccver-$libc
echo -e 'MPdir        =\nMPinc        =\nMPlib        =' >> Make.$cc$ccver-$libc
echo -e 'HPCG_INCLUDES = -I$(INCdir) -I$(INCdir)/$(arch) $(MPinc)\nHPCG_LIBS     =' >> Make.$cc$ccver-$libc
echo -e 'HPCG_OPTS     = -DHPCG_NO_MPI' >> Make.$cc$ccver-$libc
echo -e 'HPCG_DEFS     = $(HPCG_OPTS) $(HPCG_INCLUDES)' >> Make.$cc$ccver-$libc

echo "TOOLCHAIN=$TOOLCHAIN" >> Make.$cc$ccver-$libc
echo "TOOLDIR=$TOOLDIR" >> Make.$cc$ccver-$libc
echo "LD64SO=$LD64SO" >> Make.$cc$ccver-$libc
echo "CC=$TOOLDIR/bin/$TOOLCHAIN-$cc" >> Make.$cc$ccver-$libc
echo "CXX=$TOOLDIR/bin/$TOOLCHAIN-g++" >> Make.$cc$ccver-$libc
echo "LINKER=$TOOLDIR/bin/$TOOLCHAIN-ld" >> Make.$cc$ccver-$libc
echo 'CXXFLAGS =  $(HPCG_DEFS) -O3 -ffast-math -ftree-vectorize -ftree-vectorizer-verbose=0 -fopenmp -lm' >> Make.$cc$ccver-$libc
echo 'LINKFLAGS = $(HPCG_DEFS) -O3 -ffast-math -ftree-vectorize -ftree-vectorizer-verbose=0 -fopenmp -lm -lgomp' -Wl,--dynamic-linker=$LD64SO >> Make.$cc$ccver-$libc
echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> Make.$cc$ccver-$libc
echo 'LIBS =' >> Make.$cc$ccver-$libc
echo -e "ARCHIVER     = ar\nARFLAGS      = r\nRANLIB       = echo" >> Make.$cc$ccver-$libc

echo "Make.$cc$ccver-$libc has been configured"
echo "Begin compilation!"
cd ..
if [[ ! -d "build-$cc$ccver-$libc" ]]; then
  mkdir build-$cc$ccver-$libc
  cd build-$cc$ccver-$libc
elif [[ -d "build-$cc$ccver-$libc" ]]; then
  cd build-$cc$ccver-$libc
  make clean
  cd ..
  rm -r build-$cc$ccver-$libc
  mkdir build-$cc$ccver-$libc
  cd build-$cc$ccver-$libc
fi
../configure $cc$ccver-$libc
make
status=2
