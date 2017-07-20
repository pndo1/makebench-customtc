#!/bin/bash
cc=
libc=
ccver=
status=0

error_in () {
  echo "Correct libC and Compiler inputs not passed to make.sh"
  echo "Did you spell the libC and compiler names right?"
  exit
}

help () {
  echo "make-epcc.sh compiles EPCC's OpenMP microbenchmark using various toolchains"
  echo "Usage: specify a compiler, version and a libc. make.sh does the rest."
  exit
}

getinput () { #$1 - variable to set, $2 variable to read, $3 variable default $4 option2
input=$2
default=$3
option2=$4
read input
      if [ -z "$input" ] || [ "$input" == "$3" ]
       then
        export $1=$default
      elif [ "$input" == "$option2" ]
       then
        export $1=$option2
      else
        echo "input malformed. please input correct gcc version -- 7.1.0 or [6.4.0]"
        getinput $1 $input $default $option2
      fi
}

help=$(grep -o help <<< $*)
if [ "$help" == "help" ] || [ -z $1 ]
 then
   help
fi

libc=$(grep -Eow 'musl|glibc|uclibc' <<< "$*")
cc=$(grep -Eow 'gcc|clang' <<< "$*")

if [ -z "$libc" ] || [ -z "$cc" ]
 then
  error_in
fi

if [ "$cc" == "gcc" ]
 then
  ccver=$(grep -Eow '6.4.0|7.1.0' <<< "$*")
   if [ -z "$ccver" ]
    then
     echo "gcc version not specified or malformed, please input gcc version [6.4.0]"
    getinput ccver defaultgcc 6.4.0 7.1.0
   fi
 elif [ "$cc" == "clang" ]
 then
  echo "Clang unavailable at this time!"
  exit
fi

echo "Are these specifications okay? [y]"
echo "$libc $cc (version $ccver)"
rdy () {
read ready
if [ "$ready" == "y" ] || [ -z "$ready" ]
 then
  echo "Begin configuration!"
  status=1 #track status across the compile process
elif [ "$ready" == "n" ]
 then
  echo "Compilation cancelled."
  exit
else
  echo "Malformed input. Please use y/n."
  rdy
fi
}
rdy

if [ "$status" =! "1" ] #check that explicit directive to compile has been given
 then
  exit
fi

if [ -e "Makefile.defs" ]
 then
   mv Makefile.defs Makefile.defs.$(date -I).$(date +%k%M)
   touch Makefile.defs
 else
   touch Makefile.defs
 fi
TOOLCHAIN=x86_64-unknown-linux-$libc
TOOLDIR=/soft/compilers/experimental/x-tools/$cc/$ccver/$TOOLCHAIN
echo "OMPFLAG = -fopenmp -DOMPVER2 -DOMPVER3" >> Makefile.defs
echo "TOOLCHAIN=$TOOLCHAIN" >> Makefile.defs
echo "TOOLDIR=$TOOLDIR" >> Makefile.defs
echo 'LD64SO := $(wildcard $TOOLDIR/$TOOLCHAIN/sysroot/lib64/ld*so)' >> Makefile.defs
echo "CC=$TOOLDIR/bin/$TOOLCHAIN-gcc" >> Makefile.defs
echo "LD=$TOOLDIR/bin/$TOOLCHAIN-ld" >> Makefile.defs
echo 'CFLAGS =  -O1 -lm' >> Makefile.defs
echo 'LDFLAGS = -O0 -lm -lgomp -W1,--dynamic-linker=$LD64SO' >> Makefile.defs
echo "CPP = $TOOLDIR/bin/$TOOLCHAIN-cpp" >> Makefile.defs
echo 'LIBS =' >> Makefile.defs

echo "Makefile.defs has been configured"
echo "Begin compilation!"
status=2
