#!/bin/sh
sed -i \
         -e 's/#2d3045/rgb(0%,0%,0%)/g' \
         -e 's/#ffffff/rgb(100%,100%,100%)/g' \
    -e 's/#0f1120/rgb(50%,0%,0%)/g' \
     -e 's/#ffffff/rgb(0%,50%,0%)/g' \
     -e 's/#232538/rgb(50%,0%,50%)/g' \
     -e 's/#eddad4/rgb(0%,0%,50%)/g' \
	"$@"
