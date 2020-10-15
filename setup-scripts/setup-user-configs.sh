
DIR="$(cd "$( dirname "$0" )" && pwd)"

generate_gitconfig() {

  echo "
[user]
  email = $1
  name = $2
  username = $3
[diff]
  tool = vimdiff
[difftool]
  prompt = false
[color]
  ui = auto
[color \"branch\"]
  current = green bold
  local = yellow bold
  remote = blue bold
[color \"diff\"]
  meta = blue bold
  frag = blue bold
  old = red bold
  new = green bold
[color \"status\"]
  added = green bold
  changed = yellow bold
  untracked = red bold
" | tee $HOME/.gitconfig;

}

mkdir -p $HOME/.icons/default

echo "
[Icon Theme]
Inherits=Breeze
" | tee $HOME/.icons/default/index.theme

while true; do
  read -p "Do you want to configure git [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      email=
      while true; do
        read -p "Enter email or [e]xit:   " eml
        case $email in
          [Ee] ) break 2;;
          * ) email="$eml"; break;;
        esac
      done

      name=
      while true; do
        read -p "Enter name or [e]xit:   " nm
        case $name in
          [Ee] ) break 2;;
          * ) name="$nm"; break;;
        esac
      done

      username=
      while true; do
        read -p "Enter username or [e]xit:   " usrnm
        case $username in
          [Ee] ) break 2;;
          * ) username="$usrnm"; break;;
        esac
      done

      generate_gitconfig "$email" "$name" "$username"
      break;;
  esac
done

# create folders for executables
mkdir -p $HOME/.config/audio
mkdir -p $HOME/.config/display
mkdir -p $HOME/.config/conky
mkdir -p $HOME/.config/keyboard
mkdir -p $HOME/.config/i3
mkdir -p $HOME/.config/kali
mkdir -p $HOME/.config/mpd
mkdir -p $HOME/.config/network
mkdir -p $HOME/.config/touchpad
mkdir -p $HOME/.config/polybar
mkdir -p $HOME/.config/system
mkdir -p $HOME/.config/themes
mkdir -p $HOME/.config/vifm
mkdir -p $HOME/.config/vifm/scripts

# create folders for configs
mkdir -p  "$HOME/.config/Code"
mkdir -p  "$HOME/.config/Code/User"
mkdir -p  "$HOME/.config/Code - OSS"
mkdir -p  "$HOME/.config/Code - OSS/User"
mkdir -p  "$HOME/.config/gtk-3.0"

# copy vscode user settings
cp $DIR/../rice/vscode/keybindings.json "$HOME/.config/Code/User/keybindings.json"
cp $DIR/../rice/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

cp -rf $DIR/../rice/bashrc      $HOME/.bashrc

# vifm
cp -raf $DIR/../rice/vifmrc  $HOME/.config/vifm/vifmrc

# copy vim colors
mkdir -p $HOME/.vim
cp -raf $DIR/../rice/vim/*  $HOME/.vim
cp -raf $DIR/../rice/vimrc  $HOME/.vimrc

git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

# copy ranger configs
mkdir -p $HOME/.config/ranger
cp -rf $DIR/../rice/ranger/* $HOME/.config/ranger

# copy i3 config
mkdir -p $HOME/.config/i3

if [ -f $HOME/.riced ]; then
  while true; do
    read -p "Replaced existing i3 settings [yN]?   " ri3s
    case $ri3s in
      [Yy]* )
        cp -rf $DIR/../rice/config-i3      $HOME/.config/i3/config
        cp -rf $DIR/../rice/i3status.conf  $HOME/.config/i3/i3status.conf
        break;;
      * ) break;;
    esac
  done
else
  cp -rf $DIR/../rice/config-i3      $HOME/.config/i3/config
  cp -rf $DIR/../rice/i3status.conf  $HOME/.config/i3/i3status.conf
fi

sed -i 's/# exec --no-startup-id pa-applet/exec --no-startup-id pa-applet/g' $HOME/.config/i3/config

# copy ncmpcpp config
mkdir -p $HOME/.ncmpcpp
cp -rf $DIR/../rice/config-ncmpcpp $HOME/.ncmpcpp/config

# copy polybar config
mkdir -p $HOME/.config/polybar
cp -rf $DIR/../rice/config-polybar $HOME/.config/polybar/config
bash $DIR/../user-scripts/update-polybar-network-interface.sh

# copy xbindkeysrc
cp -rf $DIR/../rice/xbindkeysrc $HOME/.xbindkeysrc

# copy i3status config
sudo cp -rf $DIR/../rice/i3status.conf /etc/i3status.conf

# copy mpd config
mkdir -p $HOME/.config/mpd
mkdir -p $HOME/.config/mpd/playlists
cp -rf $DIR/../rice/mpd.conf $HOME/.config/mpd/mpd.conf

# copy neofetch config
mkdir -p $HOME/.config/neofetch
cp -rf $DIR/../rice/neofetch.conf $HOME/.config/neofetch/config.conf

# copy compton config
mkdir -p $HOME/.config/compton
cp -rf $DIR/../rice/compton.conf $HOME/.config/compton/config.conf

# copy dunst config
mkdir -p $HOME/.config/dunst
cp -rf $DIR/../rice/dunstrc $HOME/.config/dunst/dunstrc

if ! cat $HOME/.config/i3/config | grep -q 'keyboard-disabler'; then
  while true; do
    read -p "Do you want to activate keyboard disabler [yN]?   " yn
    case $yn in
      [Yy]* )
        while true; do
          xinput
          read -p "Enter device ID:   " did
          case $did in
            * )
              echo "exec --no-startup-id ~/.config/keyboard/keyboard-disabler.sh $did" | tee -a $HOME/.config/i3/config
              break 2;;
          esac
        done;;
      * ) break;;
    esac
  done
fi
