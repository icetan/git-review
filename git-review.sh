#!/bin/bash

usage() { echo "Usage: $0 [-al] [-m <annotation message>] [review id]" 1>&2; exit 1; }

# Setup args
while getopts "alm:" opt; do
case $opt in
  a) annotate=1;;
  l) list=1;;
  m) message=$OPTARG;;
  *) usage
esac
done

ARGS=(${@:$OPTIND})

prefix="review"
review_id=${ARGS[0]}
[ "$review_id" ] && prefix="review-$review_id"

git fetch --tags || exit 1

if (( $list )); then
  git tag -n -l $prefix-\*
else
  (( $annotate )) && annotate_flag="-a"
  [ "$message" ] && annotate_flag="-a -m \"$message\""
  export RTAG=$prefix-$(expr 0$(git tag -l | sed -n "s/$prefix-//p"| sort -n | tail -n1) + 1)
  git tag $annotate_flag $RTAG && git push --tags && echo $RTAG
fi
