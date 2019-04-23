
# copy executables
cp $(pwd)/scripts/volume-manager.sh                   $HOME/.config/audio/volume-manager.sh
cp $(pwd)/scripts/brightness-manager.sh               $HOME/.config/display/brightness-manager.sh
cp $(pwd)/scripts/lockscreen.sh                       $HOME/.config/display/lockscreen.sh
cp $(pwd)/scripts/mirror-display.sh                   $HOME/.config/display/mirror-display.sh
cp $(pwd)/scripts/screen-detector.sh                  $HOME/.config/display/screen-detector.sh
cp $(pwd)/scripts/use-single-display.sh               $HOME/.config/display/use-single-display.sh
cp $(pwd)/scripts/generate-conky-config.sh            $HOME/.config/conky/generate-conky-config.sh
cp $(pwd)/scripts/generate-conky-helper.sh            $HOME/.config/conky/generate-conky-helper.sh
cp $(pwd)/scripts/reinitialize-conky.sh               $HOME/.config/conky/reinitialize-conky.sh
cp $(pwd)/scripts/keyboard-disabler.sh                $HOME/.config/keyboard/keyboard-disabler.sh
cp $(pwd)/scripts/polybar.sh                          $HOME/.config/i3/polybar.sh
cp $(pwd)/scripts/polkit-launch.sh                    $HOME/.config/i3/polkit-launch.sh
cp $(pwd)/scripts/startup.sh                          $HOME/.config/i3/startup.sh
cp $(pwd)/scripts/kali-rofi.sh                        $HOME/.config/kali/rofi.sh
cp $(pwd)/scripts/kali-launch.sh                      $HOME/.config/kali/launch.sh
cp $(pwd)/scripts/spawn-mpd.sh                        $HOME/.config/mpd/spawn-mpd.sh
cp $(pwd)/scripts/network-connect.sh                  $HOME/.config/network/network-connect.sh
cp $(pwd)/scripts/update-mirrors.sh                   $HOME/.config/network/update-mirrors.sh
cp $(pwd)/scripts/toggle-touchpad.sh                  $HOME/.config/touchpad/toggle-touchpad.sh
cp $(pwd)/scripts/popup-calendar.sh                   $HOME/.config/polybar/popup-calendar.sh
cp $(pwd)/scripts/update-checker.sh                   $HOME/.config/polybar/update-checker.sh
cp $(pwd)/scripts/check-space.sh                      $HOME/.config/system/check-space.sh
cp $(pwd)/scripts/change-theme.sh                     $HOME/.config/themes/change-theme.sh
cp $(pwd)/scripts/update-polybar-network-interface.sh $HOME/.config/themes/update-polybar-network-interface.sh
cp $(pwd)/scripts/vifm-run.sh                         $HOME/.config/vifm/scripts/vifm-run.sh
cp $(pwd)/scripts/vifm-viewer.sh                      $HOME/.config/vifm/scripts/vifm-viewer.sh

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

