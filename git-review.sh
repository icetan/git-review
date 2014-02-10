#!/bin/bash

PREFIX="review"

usage() {
  echo "Usage: $0 [-acdfnv] [-m <annotation message>] [review id] [ref]" 1>&2
  exit 1
}

# Setup args
while getopts "dcvafnm:" opt; do
case $opt in
  d) dry=true;;
  c) close=true;;
  v) verbose=true;;
  a) annotate="-a";;
  f) force="-f";;
  n) new=true;;
  m) message=$OPTARG;;
  *) usage
esac
done

ARGS=(${@:$OPTIND})

id=$(echo ${ARGS[0]} | sed "s/^$PREFIX-//")
[ "$id" == "-" ] && id=""
ref="${ARGS[1]}"
exclude="^$"

git fetch --tags || exit 1

if [ ! "$new" ]; then
  [ ! "$id" ] && id="$id*"
  [ ! "$verbose" ] && exclude="$(git tag -l $PREFIX-\*-closed | sed "s/\($PREFIX-.*\)-closed/\^\1/" | paste -s -d '|' -)"
  git tag -n -l $PREFIX-$id $PREFIX-${id}.\* | grep -vE "($exclude)"
else
  if [ "$close" ]; then
    [ ! "$id" ] && echo "You need to supply an ID to close a review" 1>&2 && exit 10
    [ ! "$(git tag -l $PREFIX-$id)" ] && echo "ID supplied does not exist" 1>&2 && exit 11
    rtag=$PREFIX-$id-closed
  elif ([ "$id" ] && [ ! "$(git tag -l $PREFIX-$id)" ]); then
    rtag=$PREFIX-$id
  else
    [ "$id" ] && id="${id}."
    rtag=$PREFIX-$id$(expr 0$(git tag -l $PREFIX-$id\* | sed -n "s/^$PREFIX-$id\([0-9]*\)$/\1/p" | sort -n | tail -n1) + 1)
  fi

  if [ ! "$dry" ]; then
    if [ "$message" ]; then
      git tag $force -a -m "$message" $rtag $ref
    else
      git tag $force $annotate $rtag $ref
    fi
    ([ "$?" == "0" ] && git push --tags $force) || exit 2
  fi
  echo $rtag
fi
