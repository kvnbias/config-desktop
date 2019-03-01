#!/usr/bin/env bash
# ~/.config/kali/launch

cols=$(tput cols)
lines=$(tput lines)
if [ "$cols" -gt 67 ] && [ "$lines" -gt 34 ];then
    neofetch
fi
$1 -h
bash --rcfile ''
