
#!/bin/bash
# ~/.config/mpd/spawn-mpd.sh

if ps aux | grep mpd.conf; then
    mpd --kill
fi

mpd ~/.config/mpd/mpd.conf
mpc update
