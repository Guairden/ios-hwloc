#!/bin/sh
#-*-sh-*-

#
# Copyright © 2009 CNRS
# Copyright © 2009-2020 Inria.  All rights reserved.
# Copyright © 2009 Université Bordeaux
# Copyright © 2014 Cisco Systems, Inc.  All rights reserved.
# See COPYING in top-level directory.
#

HWLOC_top_srcdir="/Users/vhoyet/Desktop/hwloc/hwloc-master"
HWLOC_top_builddir="/Users/vhoyet/Desktop/hwloc/hwloc-master"
srcdir="$HWLOC_top_srcdir/utils/hwloc"
builddir="$HWLOC_top_builddir/utils/hwloc"
info="$builddir/hwloc-info"

HWLOC_PLUGINS_PATH=${HWLOC_top_builddir}/hwloc/.libs
export HWLOC_PLUGINS_PATH

HWLOC_DEBUG_CHECK=1
export HWLOC_DEBUG_CHECK

HWLOC_DONT_ADD_VERSION_INFO=1
export HWLOC_DONT_ADD_VERSION_INFO

: ${TMPDIR=/tmp}
{
  tmp=`
    (umask 077 && mktemp -d "$TMPDIR/fooXXXXXX") 2>/dev/null
  ` &&
  test -n "$tmp" && test -d "$tmp"
} || {
  tmp=$TMPDIR/foo$$-$RANDOM
  (umask 077 && mkdir "$tmp")
} || exit $?
file="$tmp/test-hwloc-info.output"

set -e
(
  echo "# (default)"
  $info --if synthetic --input "node:2 core:3 pu:4"
  echo
  echo "# --topology"
  $info --if synthetic --input "node:2 core:3 pu:4" --topology
  echo
  echo "# --support"
  $info --if synthetic --input "node:2 core:3 pu:4" --support
  echo
  echo "# --objects"
  $info --if synthetic --input "node:2 core:3 pu:4" --objects
  echo

  echo "# Core range"
  $info --if synthetic --input "node:2 core:3 pu:4" core:2-4
  echo

  echo "# all ancestors of PU range"
  $info --if synthetic --input "node:2 core:3 pu:4" -n --ancestors pu:10-11
  echo
  echo "# Core ancestors of PU range"
  $info --if synthetic --input "node:2 core:3 pu:4" --ancestor core pu:7-9
  echo
  echo "# L2 ancestor of PU"
  $info --if synthetic --input "node:2 core:2 l2:2 l1d:2 pu:2" --ancestor l2 pu:12
  echo
  echo "# L1 ancestor of PU range"
  $info --if synthetic --input "node:2 core:2 l2:2 l1d:2 pu:2" --ancestor l1 -s pu:7-10
  echo

  echo "# Children of L2 and Core of Node, silent"
  $info --if synthetic --input "node:2 core:2 l2:2 l1d:2 pu:2" --children -s l2:1 node:1.core:1
  echo
  echo "# L1d descendants of Core range, silent"
  $info --if synthetic --input "node:2 core:2 l2:2 l1d:2 pu:2" --descendants l1d -s core:1-2
  echo
) > "$file"
/usr/bin/diff -u -w $srcdir/test-hwloc-info.output "$file"
rm -rf "$tmp"
