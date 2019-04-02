
while true; do
  echo "Select reference display or [e]xit   "
  echo ""
  xrandr | grep connected | grep -v disconnected | while read -r line; do
    display=$(echo $line 2> /dev/null | cut -f 1 -d ' ')
    echo "$display"
  done
  echo ""
  read -p "Enter reference display or [e]xit   " rdsply
  case $rdsply in
    [Ee]* ) break;;
    * )
      while true; do
        echo "Select target display or [e]xit   "
        echo ""
        xrandr | grep connected | grep -v disconnected | while read -r line; do
          display=$(echo $line | cut -f 1 -d ' ')
          echo "$display"
        done
        echo ""
        read -p "Enter target display or [e]xit   " tdsply
        case $tdsply in
          [Ee]* ) break 2;;
          * )
            xrandr --output $tdsply --same-as $rdsply
            echo $rdsply
            echo $tdsply
            break 2;;
        esac
      done;;
  esac
done

compton --config $HOME/.config/compton/config.conf
xrdb $HOME/.Xresources
feh --bg-fill $HOME/Pictures/wallpapers/wallpaper.jpg
bash $HOME/.config/i3/polybar.sh &
bash $HOME/.config/conky/reinitialize-conky.sh

