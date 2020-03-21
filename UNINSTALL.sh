#!/bin/bash


#files
#desktop file
dir1=/usr/share/applications/
file1=/usr/share/applications/pencal.desktop; [  -e $dir1 ] && sudo  rm  $file1

dir2=/opt/pentablet/pencal
file2=/opt/pentablet/pencal/penctrl.sh; [  -e $dir2 ] && sudo  rm  $file2
file3=/opt/pentablet/pencal/calmod.sh; [  -e $dir2 ] && sudo  rm  $file3
file4=/opt/pentablet/pencal/xtcal; [  -e $dir2 ] && sudo  rm  $file4

#pencal directory
dir3=/opt/pentablet/pencal
if [ -z "$(ls $dir3)" ]; then
    sudo rm -r $dir3
fi

#pentablet dir
dir4=/opt/pentablet/
if [ -z "$(ls $dir4)" ]; then
    sudo rm -r $dir4
fi


exit
