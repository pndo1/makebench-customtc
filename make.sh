#!/bin/bash
cc=
libc=
ccver=

error_in () {
  echo "Correct libC and Compiler inputs not passed to make.sh"
  echo "Did you spell the libC and compiler names right?"
  exit
}

help () {
  echo "make.sh compiles EPCC's OpenMP microbenchmark using various toolchains"
  echo "Usage: ./make.sh C_LIB CC CC_VER"
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
  echo "here we would compile"
elif [ "$ready" == "n" ]
 then
  echo "we would not compile"
else
  echo "malformed input. please use y/n"
  rdy
fi
}
rdy
