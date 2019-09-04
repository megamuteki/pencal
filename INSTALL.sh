#!/bin/bash

if [ $(dpkg-query -W -f='${Status}' yad  2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo "yad　Install 済み"

else
	sudo apt install -y yad
fi

if [ $(dpkg-query -W -f='${Status}' xinput-calibrator  2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	echo "xinput-calibrator　Install 済み"

else
	sudo apt install -y xinput-calibrator
fi


#pencaldir
dir=/opt/pentablet/pencal; [ ! -e $dir ] && sudo  mkdir -p $dir

#penctrl.sh
sudo cp  ./penctrl.sh  $dir

#calmod.sh
sudo cp  ./calmod.sh  $dir

#xtcal
sudo cp  ./xtcal  $dir

#pencal.desktop
sudo cp  ./pencal.desktop  /usr/share/applications/

sudo chown -R $(whoami):$(whoami) $dir
sudo chmod -R +x $dir
sudo chown $(whoami):$(whoami) /usr/share/applications/pencal.desktop
sudo chmod +rx /usr/share/applications/pencal.desktop



exit
