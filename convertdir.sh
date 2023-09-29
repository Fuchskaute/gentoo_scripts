#!/usr/bin/env sh

for FILE in package.use/*;
do echo -n "# ";
   echo "$FILE" | cut -d "/" -f 2;
   cat $FILE;
done
