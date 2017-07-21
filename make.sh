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
read input
      if [ -z "$input" ] || [ "$input" == "$3" ]
       then
        export $1=$default
      elif [ "$input" == "$option2" ]
       then
        export $1=$option2
      else
        echo "input malformed. please input correct parameter -- $4 [$default]"
        getinput $1 $input $default $option2
      fi
}

export help=$(grep -o help <<< $*)
if [ "$help" == "help" ] || [ -z $1 ]
 then
   help
fi

export libc=$(grep -Eowi 'musl|glibc|uclibc|gnu' <<< "$*")
export cc=$(grep -Eowi 'gcc|clang' <<< "$*")
export bench=$(grep -Eowi 'epcc|hpcg|minife' <<< "$*")

if [ -z "$libc" ] || [ -z "$cc" ] | [ -z "$bench" ]
 then
  error_in
elif [[ "$libc" == "glibc" ]]; then
  export libc=gnu
fi

if [ "$cc" == "gcc" ]
 then
  export ccver=$(grep -Eow '6.4.0|7.1.0' <<< "$*")
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

if [[ "$bench" == "hpcg" ]]; then
  benchsrctype=source
  BENCHPATHVAR=$HPCGPATH

elif [[ "$bench" == "epcc" ]]; then
  benchsrctype=tar.gz
  BENCHPATHVAR=$EPCCPATH
elif [[ "$bench" == "minife" ]]; then
  benchsrctype=tar.gz
  BENCHPATHVAR=$MINIFEPATH
fi

echo "Please input folder of $benchsrctype of $bench or use variable [$BENCHPATHVAR]:"
read benchpathread
if [[ -z "$benchpathread" ]]; then
  export benchpath=$BENCHPATHVAR
elif [[ ! -z "$benchpathread" ]]; then
  export benchpath=$benchpathread
fi

export TOOLCHAIN=x86_64-unknown-linux-$libc
export TOOLDIR=/soft/compilers/experimental/x-tools/$cc/$ccver/$TOOLCHAIN

if [[ "$libc" == "musl" ]]; then
  export LD64SO=$TOOLDIR/$TOOLCHAIN/sysroot/lib64/$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/ | grep ld)
else
  export LD64SO=$(ls $TOOLDIR/$TOOLCHAIN/sysroot/lib64/*.so | grep ld)
fi

echo "Are these specifications okay? [y]"
echo "Compiling $bench with $libc and $cc (version $ccver)"
echo "$bench $benchsrctype located at $benchpath"
rdy () {
read ready
if [ "$ready" == "y" ] || [ -z "$ready" ]
 then
  echo "Begin configuration!"
  export status=1 #track status across the compile process
elif [ "$ready" == "n" ]
 then
  echo "Compilation cancelled."
  echo "$LD64SO"
  echo "$TOOLCHAIN"
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

echo "$bench configuration started"
./make-$bench.sh
