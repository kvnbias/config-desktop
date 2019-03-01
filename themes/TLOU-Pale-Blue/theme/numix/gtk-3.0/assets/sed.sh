#!/bin/sh
sed -i \
         -e 's/#374d5b/rgb(0%,0%,0%)/g' \
         -e 's/#eddad4/rgb(100%,100%,100%)/g' \
    -e 's/#1b2f3c/rgb(50%,0%,0%)/g' \
     -e 's/#eddad4/rgb(0%,50%,0%)/g' \
     -e 's/#374d5b/rgb(50%,0%,50%)/g' \
     -e 's/#eddad4/rgb(0%,0%,50%)/g' \
	"$@"
