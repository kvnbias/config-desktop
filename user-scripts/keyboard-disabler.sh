
#!/bin/bash
# ~/.config/keyboard/keyboard-disabler.sh

user=$(whoami)
# icon="/home/$user/.config/keyboard/on.png";
# icoff="/home/$user/.config/keyboard/off.png";

icon="/home/$user/.config/keyboard/noicon";
icoff="/home/$user/.config/keyboard/noicon";

id=$1;

if xinput list --long | grep -A $id "id=$id" | grep -q disabled;
    then
        notify-send -i $icon "Enabling keyboard..." \ "ON - Keyboard connected !";
        xinput enable $id;
    else
        notify-send -i $icoff "Disabling keyboard..." \ "OFF - Keyboard disconnected !";
	    xinput disable $id;
fi


