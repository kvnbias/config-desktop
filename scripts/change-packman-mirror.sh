
add_packman_mirror() {
  if echo "$os" | grep -q 'tumbleweed'; then
    sudo zypper rr pacman-essentials
    sudo zypper ar -cfp 90 $1/openSUSE_Tumbleweed/Essentials packman-essentials
  else
    sudo zypper rr pacman-essentials
    version=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^VERSION_ID= | sed -e "s/VERSION_ID=//" | sed 's/"//g'))
    sudo zypper ar -cfp 90 $1/openSUSE_Leap_$version/Essentials packman-essentials
  fi
  sudo zypper dup --from packman-essentials --allow-vendor-change
}

while true; do
  read -p "
Choose the closest packman repository to install. If the repository install failed,
Try other repositories, make sure to test the download speed.

Only skip this section if all mirrors are slow.

http://packman.links2linux.org/mirrors

[1] Austria: http://packman.inode.at/suse/
[2] China: http://mirrors.hust.edu.cn/packman/suse/
[3] Czech Republic: http://mirror.karneval.cz/pub/linux/packman/suse/
[4] Germany: http://packman.jacobs-university.de/suse/
[5] Germany: http://ftp.fau.de/packman/suse/
[6] Germany: http://ftp.halifax.rwth-aachen.de/packman/suse/
[7] Germany: http://ftp.gwdg.de/pub/linux/misc/packman/suse/
[8] Taiwan: http://ftp.yzu.edu.tw/linux/packman/suse/
[t] test download speed
[s] skip

Action:   " pr
  case $pr in
    [Ss]* ) break;;
    [Tt]* )
      sudo zypper -n install flash-player-ppapi freshlpayerplugin;
      sudo remove flash-player-ppapi freshlpayerplugin;
      break;;
    [1] ) add_packman_mirror "http://packman.inode.at/suse/";;
    [2] ) add_packman_mirror "http://mirrors.hust.edu.cn/packman/suse/";;
    [3] ) add_packman_mirror "http://mirror.karneval.cz/pub/linux/packman/suse/";;
    [4] ) add_packman_mirror "http://packman.jacobs-university.de/suse/";;
    [5] ) add_packman_mirror "http://ftp.fau.de/packman/suse/";;
    [6] ) add_packman_mirror "http://ftp.halifax.rwth-aachen.de/packman/suse/";;
    [7] ) add_packman_mirror "http://ftp.gwdg.de/pub/linux/misc/packman/suse/";;
    [8] ) add_packman_mirror "http://ftp.yzu.edu.tw/linux/packman/suse/";;
    * ) echo "Invalid input"
  esac
done
