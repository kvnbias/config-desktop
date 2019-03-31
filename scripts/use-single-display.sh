
generate_xrandr_command() {
  command="xrandr"
  while read -r line; do
    display=$(echo -n $line 2> /dev/null | cut -f 1 -d ' ')
    if [ "$display" == "$1" ]; then
      command+=' --output '$display' --primary --mode '$2'x'$3' --pos 0x0 --rotate normal'
    else
      command+=' --output '$display' --off'
    fi
  done < <(xrandr | grep connected)

  eval "$command"
}

while true; do
  echo "Select primary display or [e]xit   "
  echo ""
  xrandr | grep connected | grep -v disconnected | cut -f 1 -d ' '
  echo ""
  read -p "Enter display or [e]xit   " pdsply
  case $pdsply in
    [Ee]* ) break;;
    * )
      if xrandr | grep connected | grep -v disconnected | cut -f 1 -d ' ' | grep -q $pdsply; then
        while true; do
          echo "Pick a resolution or [e]xit   "
          echo "
[1] 1280x800
[2] 1280×720
[3] 1920x1080
[4] 2560x1440
[5] 3840x2160
[6] Custom
"
          read -p "Enter resolution or [e]xit   " trsltn
          case $trsltn in
            [1] )
              generate_xrandr_command "$pdsply" "1280" "800"
              break 2;;
            [2] )
              generate_xrandr_command "$pdsply" "1280" "720"
              break 2;;
            [3] )
              generate_xrandr_command "$pdsply" "1920" "1080"
              break 2;;
            [4] )
              generate_xrandr_command "$pdsply" "2560" "1440"
              break 2;;
            [5] )
              generate_xrandr_command "$pdsply" "3840" "2160"
              break 2;;
            [6] )
              while true; do
                read -p "Enter width or [e]xit   " w
                case $w in
                  [Ee]* ) break;;
                  [1-9]* )
                    while true; do
                      read -p "Enter height or [e]xit   " h
                      case $h in
                        [Ee]* ) break 2;;
                        [1-9]* )
                          generate_xrandr_command "$pdsply" "$w" "$h"
                          break 4;;
                        * ) echo Invalid Input;;
                      esac
                    done;;
                  * ) echo Invalid Input;;
                esac
              done;;
          esac
        done
        echo exists
      else
        echo "Display doesnt exists"
      fi;;
  esac
done


compton --config $HOME/.config/compton/config.conf
xrdb $HOME/.Xresources
feh --bg-scale $HOME/Pictures/wallpapers/wallpaper.jpg
bash $HOME/.config/i3/polybar.sh &
bash $HOME/.config/conky/reinitialize-conky.sh
