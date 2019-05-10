
#!/bin/bash
PWD="$(pwd)"
DIR="$(cd "$( dirname "$0" )" && pwd)"

while true; do
  read -p "Fetch 'theme' submodule in this project [yN]?   " ftsp
  case $ftsp in
    [Yy]* ) git submodule update --init themes; break;;
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
            git submodule update --init rice/images; cd "$DIR/rice/images";
            git submodule update --init wallpapers/private; cd "$PWD";
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
  read -p "Fetch 'icon-themes' submodule in this project [yN]?   " ftsp
  case $ftsp in
    [Yy]* ) git submodule update --init icon-themes; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Fetch 'dev' submodule in this project [yN]?   " ftsp
  case $ftsp in
    [Yy]* ) git submodule update --init dev; break;;
    * ) break;;
  esac
done
