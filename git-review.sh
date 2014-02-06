#!/bin/bash

PREFIX="review"

usage() {
  echo "Usage: $0 [-ld] [-m <annotation message>] [review id] [ref]" 1>&2
  exit 1
}

# Setup args
while getopts "ldm:" opt; do
case $opt in
  l) list=true;;
  d) dry=true;;
  m) message=$OPTARG;;
  *) usage
esac
done

ARGS=(${@:$OPTIND})

id=$(echo ${ARGS[0]} | sed "s/^$PREFIX-//")
[ "$id" == "-" ] && id=""
ref="${ARGS[1]}"

git fetch --tags || exit 1

if [ "$list" ]; then
  [ ! "$id" ] && id="$id*"
  git tag -n -l $PREFIX-$id $PREFIX-${id}.\*
else
  if ([ "$id" ] && [ ! "$(git tag -l $PREFIX-$id)" ]); then
    rtag=$PREFIX-$id
  else
    [ "$id" ] && id="${id}."
    rtag=$PREFIX-$id$(expr 0$(git tag -l $PREFIX-$id\* | sed -n "s/^$PREFIX-$id\([0-9]*\)$/\1/p" | sort -n | tail -n1) + 1)
  fi

  if [ ! "$dry" ]; then
    if [ "$message" ]; then
      git tag -a -m "$message" $rtag $ref
    else
      git tag -a $rtag $ref
    fi
    ([ "$?" == "0" ] && git push --tags) || exit 2
  fi
  echo $rtag
fi
