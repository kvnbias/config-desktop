#!/bin/sh
sed -i \
         -e 's/#6e2127/rgb(0%,0%,0%)/g' \
         -e 's/#fdeddd/rgb(100%,100%,100%)/g' \
    -e 's/#520a16/rgb(50%,0%,0%)/g' \
     -e 's/#fdeddd/rgb(0%,50%,0%)/g' \
     -e 's/#6e2127/rgb(50%,0%,50%)/g' \
     -e 's/#fdeddd/rgb(0%,0%,50%)/g' \
	"$@"
