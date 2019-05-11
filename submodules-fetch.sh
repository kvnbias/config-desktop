
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"

comb=false
while true; do
  read -p "Checkout to master branch on all submodules [yN]?   " combs
  case $combs in
    [Yy]* ) comb=true; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Fetch 'theme' submodule in this project [yN]?   " ftsp
  case $ftsp in
    [Yy]* )
      git submodule update --init themes;
      if [ "$comb" = true ]; then
        cd "$DIR/themes" && git checkout master
      fi
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Fetch 'wallpapers' submodule in this project [yN]?   " ftsp
  case $ftsp in
    [Yy]* )
      while true; do
        read -p "Fetch 'private wallpapers' submodule in this project (Needs access on the repo) [yN]?   " ftsp
        case $ftsp in
          [Yy]* )
            git submodule update --init rice/images;
            if [ "$comb" = true ]; then
              cd "$DIR/rice/images" && git checkout master
            fi

            git submodule update --init wallpapers/private;

            if [ "$comb" = true ]; then
              cd "$DIR/rice/images/wallpapers/private" && git checkout master;
            fi

            cd "$DIR"
            break 2;;
          * )
            git submodule update --init rice/images;
            break 2;;
        esac
      done
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Fetch 'icon-themes' submodule in this project (Takes a lot of space & will slow down editors) [yN]?   " ftsp
  case $ftsp in
    [Yy]* )
      git submodule update --init icon-themes;
      if [ "$comb" = true ]; then
        cd "$DIR/icon-themes" && git checkout master && cd "$DIR"
      fi
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Fetch 'dev' submodule in this project [yN]?   " ftsp
  case $ftsp in
    [Yy]* )
      git submodule update --init dev;
      if [ "$comb" = true ]; then
        cd "$DIR/dev" && git checkout master && cd "$DIR"
      fi
      break;;
    * ) break;;
  esac
done
