#!/bin/bash


#-------使用するcaldataを変数にする。
calfile=$HOME/calini.txt
callines=()
while IFS= read -r callines; do

callines=("${callines[@]}"  "$callines")
done <"$calfile"

# ファンクション用にcallinesをコピーする
calfunc=()
calfunc=("${callines[@]}")

calmod=$(yad --title="キャルデータ登録変更" \
 --geometry=400x400+512+384 \
--form \
--field="登録１":CB \
"${callines[1]} ! ${callines[0]}! ${callines[2]} ! ${callines[3]} ! ${callines[4]}  !  \
${callines[5]} ! ${callines[6]} " \
--field="登録2":CB \
"${callines[2]} ! ${callines[0]}! ${callines[1]} ! ${callines[3]} ! ${callines[4]}  !  \
${callines[5]} ! ${callines[6]} " \
--field="登録3":CB \
"${callines[3]} ! ${callines[0]}! ${callines[1]} ! ${callines[2]} ! ${callines[4]}  !  \
${callines[5]} ! ${callines[6]} " \
--field="登録4":CB \
"${callines[4]} ! ${callines[0]}! ${callines[1]} ! ${callines[2]} ! ${callines[3]}  !  \
${callines[5]} ! ${callines[6]} " \
--field="登録5":CB \
"${callines[5]} ! ${callines[0]}! ${callines[1]} ! ${callines[2]} ! ${callines[3]}  !  \
${callines[6]} ! ${callines[6]} " \
--field="登録6":CB \
"${callines[6]} ! ${callines[0]}! ${callines[1]} ! ${callines[2]} ! ${callines[3]}  !  \
${callines[4]} ! ${callines[5]} ! ${callines[0]} ! ${callines[7]} " \
--buttons-layout=edge \
--button="登録して戻る。":12 \
--button="gtk-cancel":13 \
--button="gtk-quit":15 \
--button="gtk-ok":16 )

calfuncsw=$?


case  $calfuncsw in
 
     12)
         echo $calmod | tr '|' '\n' |sed -n '$!p' | sed -e 's/^[ ]*//g' > $HOME/calini.txt
         bash penctrl.sh
         exit 0
         ;;

     13) 
         bash penctrl.sh
         exit 0
         ;;

     15)
         exit 0
         ;;

     16)
         echo $calmod | tr '|' '\n' |sed -n '$!p' | sed -e 's/^[ ]*//g' > $HOME/calini.txt
         exit 0
         ;;


esac         


exit  0
