#!/usr/bin/env bash

# trivial test
# launch from the root directory like: tests/test.sh tardis

file_src=$1
file_tmp=$file_src.tmp

cat "$file_src" > "$file_tmp" 
./tardis -c "$file_tmp"
./tardis -d "$file_tmp".dis
diff "$file_tmp" "$file_tmp".dis.undis
rm "$file_tmp" "$file_tmp".dis "$file_tmp".dis.undis

 
