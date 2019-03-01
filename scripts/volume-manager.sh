
#!/bin/bash

val=$1

icon="/home/$user/.config/audio/noicon";

mute=false
if pactl list sinks | grep -q 'Mute: yes'; then
  mute=true
fi

sink=$( pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1 )


if [[ $val =~ "mute" ]]; then
  pactl set-sink-mute $sink toggle

  if pactl list sinks | grep -q 'Mute: yes'; then
    notify-send -i $icon -t 1000 "Volume" "Mute volume is ON";
  else
    notify-send -i $icon -t 1000 "Volume" "Mute volume is OFF";
  fi
else
  if [ "$mute" = true ];then
    pactl set-sink-mute $sink toggle
  fi

  pactl set-sink-volume $sink $val

  volume=$( pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $sink + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,' )
  notify-send -i $icon -t 1000 "Volume" "Volume adjusted to $volume%";
fi

