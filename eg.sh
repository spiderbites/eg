#!/usr/bin/env bash

USAGE="Usage: eg [-a -t -l] command"
FORMAT="Format: \n\t* title\n\t** example\n\tdescription"
DATA_DIR="./eg.d"
EDITOR="vi"

show_all=false
show_top=false

while getopts labth\? option; do
  case "$option" in
    l    ) basename $DATA_DIR/*; exit;;
    [h\?]) echo $USAGE; echo -e "\n$FORMAT"; exit;;
    a    ) show_all=true; shift;; 
    [bt] ) show_top=true; shift;;
  esac
done
if [ "$#" -eq 0 ]; then
  echo $USAGE; echo -e "\n$FORMAT"; exit
fi

if [ "$#" -ge 2 ]; then
  path=$DATA_DIR/$2;
  if [ -e $path ]; then
    case "$1" in
      add ) echo "that already exists. use \"eg edit $2\"";;
      edit) $EDITOR $path;;
      rm  ) echo "really? (y/n)"; read a; if [ $a = 'y' ]; then rm $path; fi;;
    esac
  else
    case "$1" in
      add ) $EDITOR $path;;
      edit) echo "not added yet. use \"eg add $2\"";;
      rm  ) echo "nothing to remove";;
    esac
  fi
  exit;
fi

RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
GREEN=$'\033[0;32m'
GRAY=$'\033[90m'

NL=$'\\\n'

TITLE="${GRAY}${NL}# "
EXAMPLE=$GREEN

command=$1
cmd_eg_file=$DATA_DIR/$command

if [ ! -e $cmd_eg_file ]; then echo "no example file. use \"eg add $command\""; exit; fi

(while read line; do
  if ! $show_all; then
    case "$line" in
      \*\ ?*  ) if ! $show_top; then continue; fi;;
      \*\*\ ?*) show=true;;
             *) continue;;
    esac
  fi

  line=$(echo "$line" | sed "s/^\* /$TITLE/" | sed "s/^\*\* /$EXAMPLE/")

  echo "$RED$line"
done < $cmd_eg_file

echo) | more -R

