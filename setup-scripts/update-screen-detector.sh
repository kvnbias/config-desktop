
DIR="$(cd "$( dirname "$0" )" && pwd)"
mkdir -p $HOME/.config/display
cp -raf $DIR/../user-scripts/screen-detector.sh   $HOME/.config/display/screen-detector.sh

while true; do
  read -p "Using a low res mac [yN]?   " yn
  case $yn in
    [Yy]* )
      sed -i "s/IS_LOW_RES_MAC/true/g" $HOME/.config/display/screen-detector.sh
      break;;
    * )
      sed -i "s/IS_LOW_RES_MAC/false/g" $HOME/.config/display/screen-detector.sh
      break;;
  esac
done

while true; do
  read -p "
Target Base Resolution:

[a] 1920x1080
[b] 2560x1440
[c] 3840x2160
[d] Custom

Target:   " tr
  case $tr in
    [Aa]* )
      sed -i "s/WIDTH/1920/g" $HOME/.config/display/screen-detector.sh
      sed -i "s/HEIGHT/1080/g" $HOME/.config/display/screen-detector.sh
      break;;
    [Bb]* )
      sed -i "s/WIDTH/2560/g" $HOME/.config/display/screen-detector.sh
      sed -i "s/HEIGHT/1440/g" $HOME/.config/display/screen-detector.sh
      break;;
    [Cc]* )
      sed -i "s/WIDTH/3840/g" $HOME/.config/display/screen-detector.sh
      sed -i "s/HEIGHT/2160/g" $HOME/.config/display/screen-detector.sh
      break;;
    [Dd]* )
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
                  sed -i "s/WIDTH/$w/g" $HOME/.config/display/screen-detector.sh
                  sed -i "s/HEIGHT/$h/g" $HOME/.config/display/screen-detector.sh
                  break 3;;
                * ) echo Invalid Input;;
              esac
            done;;
          * ) echo Invalid Input;;
        esac
      done;;
  esac
done
