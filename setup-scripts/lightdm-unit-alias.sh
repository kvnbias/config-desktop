
#!/bin/bash

lightdmUnit='/usr/lib/systemd/system/lightdm.service'
if [ -f /usr/lib/systemd/system/lightdm.service ]; then
  lightdmUnit='/usr/lib/systemd/system/lightdm.service'
else
  if [ -f /etc/systemd/system/lightdm.service ]; then
    lightdmUnit='/etc/systemd/system/lightdm.service'
  fi
fi

# If lightdm unit doesnt exists it may be manage by other unit.
# In ubuntu, ubuntu lets you pick your default display manager when lightdm is installed,
# instead of settings a daemon
if [ -f $lightdmUnit ]; then
  if cat $lightdmUnit | grep -q 'Alias=display-manager.service'; then
    echo 'Alias already exists'
  else
    if cat $lightdmUnit | grep -q '\[Install\]'; then
      echo 'Install already exists'
    else
      echo '[Install]' | sudo tee -a $lightdmUnit
    fi

    echo 'Alias=display-manager.service' | sudo tee -a $lightdmUnit
  fi
fi
