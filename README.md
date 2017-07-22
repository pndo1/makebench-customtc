# makebench-customtc
Scripts making several benchmarks using various toolchains.

Generally for use with toolchains compiled using Crosstool-NG, but base path of toolchains is hardcoded.

Usage:

./make.sh BENCH COMPILER COMPILER-VERSION LIBC

BENCH: benchmark choices. choose from epcc (openmpbench), hpcg and minife. you can also compile mpich.
COMPILER: gcc (for now).
COMPILER-VERSION: 7.1.0 or 6.4.0. make.sh will prompt and set a default compiler version if one is not passed.
LIBC: glibc, musl or uclibc.

Location of source:

make.sh will prompt for the paths of certain files or folders depending on the benchmark selected.

epcc will ask for the path to openmpbench_C_v31.tar.gz (the folder containing the archive).
miniFE will ask for the path to minife.tar.gz (the folder containing the archive).
hpcg will ask for the hpcg source folder.
mpich will ask for the mpich source folder.

These can all be set prior to running ./make.sh by setting the variables EPCCPATH, MINIFEPATH, HPCGPATH or MPICHPATH.

Output folder:

./make.sh will print the output directory at the end of compilation. Usually it will be $bench-$compiler$compiler-version-$libc.

Notes on individual programs:

Using make.sh to compile miniFE and HPCG depends on an MPICH that's been compiled by make.sh. Please compile MPICH (and set MPICHPATH) before using make.sh to compile miniFE or HPCG. 
