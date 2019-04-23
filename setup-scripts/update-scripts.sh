
DIR="$(cd "$( dirname "$0" )" && pwd)"

# copy executables
cp $DIR/../user-scripts/volume-manager.sh                   $HOME/.config/audio/volume-manager.sh
cp $DIR/../user-scripts/brightness-manager.sh               $HOME/.config/display/brightness-manager.sh
cp $DIR/../user-scripts/lockscreen.sh                       $HOME/.config/display/lockscreen.sh
cp $DIR/../user-scripts/mirror-display.sh                   $HOME/.config/display/mirror-display.sh
cp $DIR/../user-scripts/screen-detector.sh                  $HOME/.config/display/screen-detector.sh
cp $DIR/../user-scripts/use-single-display.sh               $HOME/.config/display/use-single-display.sh
cp $DIR/../user-scripts/generate-conky-config.sh            $HOME/.config/conky/generate-conky-config.sh
cp $DIR/../user-scripts/generate-conky-helper.sh            $HOME/.config/conky/generate-conky-helper.sh
cp $DIR/../user-scripts/reinitialize-conky.sh               $HOME/.config/conky/reinitialize-conky.sh
cp $DIR/../user-scripts/keyboard-disabler.sh                $HOME/.config/keyboard/keyboard-disabler.sh
cp $DIR/../user-scripts/polybar.sh                          $HOME/.config/i3/polybar.sh
cp $DIR/../user-scripts/polkit-launch.sh                    $HOME/.config/i3/polkit-launch.sh
cp $DIR/../user-scripts/startup.sh                          $HOME/.config/i3/startup.sh
cp $DIR/../user-scripts/kali-rofi.sh                        $HOME/.config/kali/rofi.sh
cp $DIR/../user-scripts/kali-launch.sh                      $HOME/.config/kali/launch.sh
cp $DIR/../user-scripts/spawn-mpd.sh                        $HOME/.config/mpd/spawn-mpd.sh
cp $DIR/../user-scripts/network-connect.sh                  $HOME/.config/network/network-connect.sh
cp $DIR/../user-scripts/update-mirrors.sh                   $HOME/.config/network/update-mirrors.sh
cp $DIR/../user-scripts/toggle-touchpad.sh                  $HOME/.config/touchpad/toggle-touchpad.sh
cp $DIR/../user-scripts/popup-calendar.sh                   $HOME/.config/polybar/popup-calendar.sh
cp $DIR/../user-scripts/update-checker.sh                   $HOME/.config/polybar/update-checker.sh
cp $DIR/../user-scripts/check-space.sh                      $HOME/.config/system/check-space.sh
cp $DIR/../user-scripts/change-theme.sh                     $HOME/.config/themes/change-theme.sh
cp $DIR/../user-scripts/update-polybar-network-interface.sh $HOME/.config/themes/update-polybar-network-interface.sh
cp $DIR/../user-scripts/vifm-run.sh                         $HOME/.config/vifm/scripts/vifm-run.sh
cp $DIR/../user-scripts/vifm-viewer.sh                      $HOME/.config/vifm/scripts/vifm-viewer.sh

# make executables
sudo chmod +x $HOME/.config/audio/volume-manager.sh
sudo chmod +x $HOME/.config/display/brightness-manager.sh
sudo chmod +x $HOME/.config/display/lockscreen.sh
sudo chmod +x $HOME/.config/display/mirror-display.sh
sudo chmod +x $HOME/.config/display/screen-detector.sh
sudo chmod +x $HOME/.config/display/use-single-display.sh
sudo chmod +x $HOME/.config/conky/generate-conky-config.sh
sudo chmod +x $HOME/.config/conky/generate-conky-helper.sh
sudo chmod +x $HOME/.config/conky/reinitialize-conky.sh
sudo chmod +x $HOME/.config/keyboard/keyboard-disabler.sh
sudo chmod +x $HOME/.config/i3/polybar.sh
sudo chmod +x $HOME/.config/i3/polkit-launch.sh
sudo chmod +x $HOME/.config/i3/startup.sh
sudo chmod +x $HOME/.config/kali/rofi.sh
sudo chmod +x $HOME/.config/kali/launch.sh
sudo chmod +x $HOME/.config/mpd/spawn-mpd.sh
sudo chmod +x $HOME/.config/network/network-connect.sh
sudo chmod +x $HOME/.config/network/update-mirrors.sh
sudo chmod +x $HOME/.config/touchpad/toggle-touchpad.sh
sudo chmod +x $HOME/.config/polybar/popup-calendar.sh
sudo chmod +x $HOME/.config/polybar/update-checker.sh
sudo chmod +x $HOME/.config/themes/check-space.sh
sudo chmod +x $HOME/.config/themes/change-theme.sh
sudo chmod +x $HOME/.config/themes/update-polybar-network-interface.sh
sudo chmod +x $HOME/.config/vifm/scripts/vifm-run.sh
sudo chmod +x $HOME/.config/vifm/scripts/vifm-viewer.sh

