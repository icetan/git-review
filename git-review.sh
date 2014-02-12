#!/bin/bash

IAM=${0##*/}
PREFIX="review"

usage() {
  echo "Usage: $IAM [-dfhv] [ -l | -n | -r | -c ] [-a | -m <annotation message>] [id [ref]]" 1>&2
  exit 1
}

# Setup args
while getopts "acdfhlm:nrv" opt; do
case $opt in
  a) annotate="-a";;
  c) close=true;;
  d) dry=true;;
  f) force="-f";;
  l) list=true;;
  m) message="$OPTARG";;
  n) new=true;;
  r) request=true; annotate="-a";;
  v) verbose=true;;
  *|h) usage
esac
done

ARGS=(${@:$OPTIND})

id=$(echo ${ARGS[0]} | sed "s/^$PREFIX-//")
[ "$id" == "-" ] && id=""
ref="${ARGS[1]}"
exclude="^$"

([ "$new" ] || ([ ! "$list" ] && [ "$id" ])) && new=true
([ "$request" ] || [ "$close" ] || [ "$new" ]) && create=true

git fetch --tags || exit 1

if [ "$create" ]; then
  # Check if ID is required.
  ([ "$request" ] || [ "$close" ]) && [ ! "$id" ] && \
    echo "Error: You need to supply an ID." 1>&2 && exit 10
  # Check if ID needs to exist.
  ([ "$request" ] || [ "$close" ]) && [ ! "$(git tag -l $PREFIX-$id)" ] && \
    echo "ID supplied does not exist." 1>&2 && exit 11
  # Check if ID needs to be calculated.
  ([ ! "$id" ] || [ "$request" ]) && calcid=true

  if [ "$close" ]; then
    id="$id-closed"
  elif [ "$calcid" ]; then
    [ "$request" ] && id="${id}."
    id=$id$(expr 0$(git tag -l $PREFIX-$id\* | sed -n "s/^$PREFIX-$id\([0-9]*\)$/\1/p" | sort -n | tail -n1) + 1)
  fi

  rtag=$PREFIX-$id

  if [ ! "$dry" ]; then
    if [ "$message" ]; then
      git tag $force -a -m "$message" $rtag $ref
    else
      git tag $force $annotate $rtag $ref
    fi
    ([ "$?" == "0" ] && git push --tags $force) || exit 2
  fi
  echo $rtag
else
  [ ! "$id" ] && id="*"
  [ ! "$verbose" ] && exclude="$(git tag -l $PREFIX-\*-closed | sed "s/\($PREFIX-.*\)-closed/\^\1/" | paste -s -d '|' -)"
  git tag -n -l $PREFIX-$id $PREFIX-${id}-closed $PREFIX-${id}.\* | grep -vE "($exclude)"
fi
