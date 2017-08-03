#!/bin/bash
cd $benchpath
cd setup

if [ -e "Make.$cc$ccver-$libc-static" ]
 then
   mv Make.$cc$ccver-$libc-static-static Make.$cc$ccver-$libc-static.$(date -I).$(date +%k%M)
   touch Make.$cc$ccver-$libc-static
 else
   touch Make.$cc$ccver-$libc-static
 fi

echo $LD64SO
echo -e 'SHELL        = /bin/sh\nCD           = cd\n\nCP           = cp\nLN_S         = ln -s -f\nMKDIR        = mkdir -p\nRM           = /bin/rm -f\nTOUCH        = touch' >> Make.$cc$ccver-$libc-static
echo -e 'TOPdir       = .\nSRCdir       = $(TOPdir)/src\nINCdir       = $(TOPdir)/src\nBINdir       = $(TOPdir)/bin' >> Make.$cc$ccver-$libc-static
echo -e "MPdir        = $MPICHPATH/mpich-$cc$ccver-$libc" >> Make.$cc$ccver-$libc-static
echo -e 'MPinc        = -I$(MPdir)/include' >> Make.$cc$ccver-$libc-static
echo -e 'MPlib        = $(Mpdir)/lib/libmpi.a' >> Make.$cc$ccver-$libc-static
echo -e 'HPCG_INCLUDES = -I$(INCdir) -I$(INCdir)/$(arch) $(MPinc)\nHPCG_LIBS     =' >> Make.$cc$ccver-$libc-static
echo -e 'HPCG_OPTS     = ' >> Make.$cc$ccver-$libc-static
echo -e 'HPCG_DEFS     = $(HPCG_OPTS) $(HPCG_INCLUDES)' >> Make.$cc$ccver-$libc-static

echo "TOOLCHAIN=$TOOLCHAIN" >> Make.$cc$ccver-$libc-static
echo "TOOLDIR=$TOOLDIR" >> Make.$cc$ccver-$libc-static
echo "LD64SO=$LD64SO" >> Make.$cc$ccver-$libc-static
echo "CC=$MPICHPATH/mpich-$cc$ccver-$libc/bin/mpicc" >> Make.$cc$ccver-$libc-static
echo "CXX=$MPICHPATH/mpich-$cc$ccver-$libc/bin/mpic++" >> Make.$cc$ccver-$libc-static
#echo "LINKER=$TOOLDIR/bin/$TOOLCHAIN-ld" >> Make.$cc$ccver-$libc-static
echo 'CXXFLAGS =  $(HPCG_DEFS) -static -O3 -ffast-math -ftree-vectorize -ftree-vectorizer-verbose=0 -fopenmp -lm '-Wl,--dynamic-linker=$LD64SO,-rpath,"$TOOLDIR"/"$TOOLCHAIN"/sysroot/lib64,-rpath,$MPICHPATH/mpich-$cc$ccver-$libc/lib,-L$toollibs/,-L$MPICHPATH/mpich-$cc$ccver-$libc/lib >> Make.$cc$ccver-$libc-static
#echo 'LINKFLAGS = $(HPCG_INCLUDES) -lm -lgomp' --dynamic-linker=$LD64SO >> Make.$cc$ccver-$libc-static
echo -e 'LINKER       = $(CXX)\nLINKFLAGS    = $(CXXFLAGS)' >> Make.$cc$ccver-$libc-static
echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> Make.$cc$ccver-$libc-static
echo 'LIBS =' >> Make.$cc$ccver-$libc-static
echo -e "ARCHIVER     = ar\nARFLAGS      = r\nRANLIB       = echo" >> Make.$cc$ccver-$libc-static

echo "Make.$cc$ccver-$libc-static has been configured"
echo "Begin compilation!"
cd ..
if [[ ! -d "$cc$ccver-$libc-static" ]]; then
  mkdir $cc$ccver-$libc-static
  cd $cc$ccver-$libc-static
elif [[ -d "$cc$ccver-$libc-static" ]]; then
  cd $cc$ccver-$libc-static
  make clean
  cd ..
  rm -r $cc$ccver-$libc-static
  mkdir $cc$ccver-$libc-static
  cd $cc$ccver-$libc-static
fi
../configure $cc$ccver-$libc-static
make
echo "Finished with HPCG"
echo "Path to spec:"
echo "$benchpath/$cc$ccver-$libc-static"
status=2
