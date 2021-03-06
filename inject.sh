#!/usr/bin/env bash

proc=${1:-$(ps $(pidof gameoverlayui) | tail -n1 | cut -d\- -f2 | cut -d\  -f2)}
if ! [[ $proc =~ ^[0-9]+$ ]]; then
   echo "Couldn't find process! Are you sure a game is running?" >&2; exit 1
fi

if grep -q "libcathook.so" /proc/"$proc"/maps; then
  echo already loaded
  exit
fi

echo loading "$(realpath cathook/libcathook.so)" to "$proc"
gdb -n -q -batch \
  -ex "attach $proc" \
  -ex "set \$dlopen = (void*(*)(char*, int)) dlopen" \
  -ex "call \$dlopen(\"$(realpath cathook/libcathook.so)\", 1)" \
  -ex "call dlerror()" \
  -ex 'print (char *) $2' \
  -ex "continue" \
  -ex "backtrace"
