#!/bin/sh
sed -i \
         -e 's/rgb(0%,0%,0%)/#43313d/g' \
         -e 's/rgb(100%,100%,100%)/#eddad4/g' \
    -e 's/rgb(50%,0%,0%)/#301e2a/g' \
     -e 's/rgb(0%,50%,0%)/#362130/g' \
 -e 's/rgb(0%,50.196078%,0%)/#362130/g' \
     -e 's/rgb(50%,0%,50%)/#43313d/g' \
 -e 's/rgb(50.196078%,0%,50.196078%)/#43313d/g' \
     -e 's/rgb(0%,0%,50%)/#eddad4/g' \
	"$@"
