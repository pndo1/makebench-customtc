#!/bin/bash
cc=
libc=
ccver=
status=0
bench=
error_in () {
  echo "Correct benchmark, libC and Compiler inputs not passed to make.sh"
  echo "Did you spell everything correctly?"
  exit
}

help () {
  echo "make-hpcg.sh compiles the HPCG benchmark using various toolchains"
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

libc=$(grep -Eowi 'musl|glibc|uclibc|gnu' <<< "$*")
cc=$(grep -Eowi 'gcc|clang' <<< "$*")
bench=$(grep -Eowi 'epcc|hpcg|minife' <<< "$*")

if [ -z "$libc" ] || [ -z "$cc" ] | [ -z "$bench"]
 then
  error_in
elif [[ "$libc" == "glibc" ]]; then
  libc=gnu
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
echo "Compiling $bench with $libc and $cc (version $ccver)"
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

if [ $status != 1 ] #check that explicit directive to compile has been given
 then
  exit
fi

TOOLCHAIN=x86_64-unknown-linux-$libc
TOOLDIR=/soft/compilers/experimental/x-tools/$cc/$ccver/$TOOLCHAIN

if [[ "$libc" == "musl" ]]; then
  LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/ | grep ld)
else
  LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/*.so | grep ld)
fi

if [[ "$bench" == "minife" ]]; then
  echo "MiniFE not supported at this time."
elif [[ "$bench" == "hpcg" ]]; then
  echo "HPCG configuration started"
  ./make-hpcg.sh
elif [[ "$bench" == "epcc" ]]; then
  echo "EPCC OpenMP microbenchmark configuration started"
  ./make-epcc.sh
fi
