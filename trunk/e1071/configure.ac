AC_PREREQ(2.50)
AC_INIT([DESCRIPTION])

: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi
CXX=`${R_HOME}/bin/R CMD config CXX`

AC_PROG_GCC_TRADITIONAL
AC_PROG_CXX

if test "${GCC}" = yes; then
  gxx_version=`${CXX} --version`
  case ${gxx_version} in
    2.96*)
    echo "g++ 2.96 is not functional. Please upgrade your C++-compiler."
    exit 1
    ;;
  esac
fi