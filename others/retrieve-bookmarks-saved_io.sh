#!/bin/bash

_devkey=$1
_key=$2

if ! curl --silent "http://devapi.saved.io/bookmarks?limit=1&devkey=$_devkey&key=$_key" | grep -q bk_id; then
  echo Nao autenticado
  exit
fi

retrieve_list () {
  local _l=$1
  curl --silent "http://devapi.saved.io/bookmarks?limit=10000&devkey=$_devkey&key=$_key&list=$_l" | jq -r 'sort_by(.bk_url)|.[]| .bk_url + " " + .bk_title'
}

_lists=()

retrieve_list level0 | while read url title
do
  if [[ $url =~ ^(.*)\.saved\.io$ ]]
  then
     _lists+=( "${BASH_REMATCH[1]}" )
  else
     echo "$title $url"
  fi
done

set -x
for l in "${_lists[@]}"
do
  echo "#$l ?????"
  retrieve_list $l | while read url title
  do
    if [[ $url =~ ^(.*)\.saved\.io$ ]]
    then
       echo "Ops ${BASH_REMATCH[1]}"
    else
       echo "$title $url"
    fi
  done
done
