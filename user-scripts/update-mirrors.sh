#!/bin/bash

sudo reflector --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
