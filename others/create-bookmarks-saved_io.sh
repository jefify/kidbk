#!/bin/bash

if ! [ -r "$1" ]; then
  echo cannot read "$1"
  exit
fi

_devkey=$2
_key=$3

if ! curl --silent "http://devapi.saved.io/bookmarks?devkey=$_devkey&key=$_key" | grep -q bk_id; then
  echo Nao autenticado
  exit
fi

# inicial
_list="level0"
_title=""
_url=""

_create_bookmark () {
  local _l=$1
  echo "## Creating $_l >> $_title"
  echo "  $_url"
  curl http://devapi.saved.io/bookmarks/ -X POST \
    -F "devkey=$_devkey" \
    -F "key=$_key" \
    -F "url=$_url" \
    -F "title=$_title" \
    -F "list=$_l"
}

while read L; do
  if [[ "$L" =~ ^\#([^\ ][^\ ]*)\ (.*) ]]; then
    _list="${BASH_REMATCH[1]}"
    _url="${_list}.saved.io"
    _title="${BASH_REMATCH[2]}"
    _create_bookmark level0
  elif [[ "$L" =~ ^(.*)\ (http.*) ]]; then
    _title="${BASH_REMATCH[1]}"
    _url="${BASH_REMATCH[2]}"
    _create_bookmark $_list
  else
    echo o que??
    exit
  fi
done <$1
