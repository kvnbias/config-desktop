
#!/bin/bash

echo '
# Match on all types of devices but joysticks
Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "NaturalScrolling" "true"
EndSection

Section "InputClass"
  Identifier "libinput keyboard catchall"
  MatchIsKeyboard "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "Tapping" "true"
  Option "ScrollMethod" "twofinger"
  Option "NaturalScrolling" "true"
  Option "ClickMethod" "clickfinger"
  Option "TappingDrag" "true"
EndSection

Section "InputClass"
  Identifier "libinput touchscreen catchall"
  MatchIsTouchscreen "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput tablet catchall"
  MatchIsTablet "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection
' | sudo tee /usr/share/X11/xorg.conf.d/40-libinput.conf