#!/bin/bash

#COMMON Variable
opdir=/opt/pentablet/pencal
export PATH="$PATH:$opdir"

#-------ペンとモニタのリストを＄HOMEに作成する。----------------
xinput_calibrator --list | sed -e '/Pad/d' -e  '/pad/d' -e '/Mouse/d' -e '/mouse/d' -e '/Keyobard/d' -e '/keyboard/d' -e '/eraser/d' >  $HOME/penlist.txt
xrandr --listmonitors | awk -F'[ ]'  'NR>1' >  $HOME/monlist.txt


#--------使用するペン入力を変数にする。---------------
penfile=$HOME/penlist.txt
penlines=()
while IFS= read -r penlines; do

penlines=("${penlines[@]}" "$penlines")

done <"$penfile"

#--------使用するモニタ入力を変数にする。-----------------

monfile=$HOME/monlist.txt
monlines=()
while IFS= read -r monlines; do

monlines=("${monlines[@]}" "$monlines")

done <"$monfile"

 
#-------使用するCALINIを変数にする。--------------
#-------caliniがなかった時空ファイルを作成する。
touch $HOME/calini.txt
calfile=$HOME/calini.txt
#-------Cancel用のバックアップを作成する------------

#cp  $HOME/calini.txt   $HOME/calback.txt


callines=()
while IFS= read -r callines; do

callines=("${callines[@]}"  "$callines")
done <"$calfile"

#-------一時ファイルを削除する。----------
rm  $HOME/penlist.txt
rm  $HOME/monlist.txt

#-------CALを実行する。
calout=$(yad  --title="ペンコントロール実行" \
--geometry=400x400+512+384 \
--form \
--field="PENList:CB" \
"${penlines[1]} !${penlines[2]} !${penlines[3]} !${penlines[4]} " \
--field="MonitorList:CB" \
"${monlines[1]} !${monlines[2]} !${monlines[3]} !${monlines[4]} " \
--field="この組合せでキャリブレーション実行":FBTN 'bash -c " echo 10 ; kill -USR1 $YAD_PID"' \
--field="この組合せのキャリブレーションデータを登録":FBTN 'bash -c " echo 12 ; kill -USR1 $YAD_PID"' \
--field="キャルデータの再編成":FBTN 'bash -c " echo 14  ; kill -USR1 $YAD_PID"' \
--field="この組合せを切断（マルチペンタブ非対応アプリ用）":FBTN 'bash -c " echo 16  ; kill -USR1 $YAD_PID"' \
--field="この組合せを接続（マルチペンタブ非対応アプリ用）":FBTN 'bash -c " echo 18  ; kill -USR1 $YAD_PID"' \
--field="登録PCAL1":LBL 'bash -c ""' \
--field="${callines[1]}----登録CAL実行":FBTN 'bash -c " echo 21 ; kill -USR1 $YAD_PID"' \
--field="登録CAL2":LBL 'bash -c ""' \
--field="${callines[2]}----登録CAL実行":FBTN 'bash -c " echo 22 ; kill -USR1 $YAD_PID"' \
--field="登録CAL3":LBL 'bash -c ""' \
--field="${callines[3]}----登録CAL実行":FBTN 'bash -c " echo 23 ; kill -USR1 $YAD_PID"' \
--field="登録CAL4":LBL 'bash -c ""' \
--field="${callines[4]}----登録CAL実行":FBTN 'bash -c " echo 24 ; kill -USR1 $YAD_PID"' \
--field="登録CAL5":LBL 'bash -c ""' \
--field="${callines[5]}----登録CAL実行":FBTN 'bash -c " echo 25 ; kill -USR1 $YAD_PID"' \
--field="登録CAL6":LBL 'bash -c " "' \
--field="${callines[6]}----登録CAL実行":FBTN 'bash -c " echo 26 ; kill -USR1 $YAD_PID"' \
--button="gtk-ok":100 )



#------BottunのIDを使用する時に、使用する。奇数の時は、IDのみが出力される。偶数の時は、yadの出力も出る。
#--------calout から余計な文字列を削除して、calinfoとする。
#--------calinfoからAwkで必要なデータを取り出す。

calinfo=$(echo $calout  |  awk '{$NF="";print $0}') 

#--------penmopinforからAwkでcalinfoとpeninfoに必要なデータを取り出す。
penmoninfo=$(echo $calinfo  | awk '{print substr($0,4,length($0))}' )

#--------penmoninforからAwkでmoninfoに必要なデータを取り出す。
moninfo=$(echo $penmoninfo  | awk '{print substr($0,index($0,"|")+2,length($0))}' )

#--------penmoninforからAwkでpeninfoに必要なデータを取り出す。
peninfo=$(echo $penmoninfo |awk -F '|' '{print $1}' )

#--------penswは、作業項目毎のFlagにする。
pensw=$(echo $calinfo | awk  '{print $1}')

#--------pennameは、pendiviceのname
penname=$(echo $calinfo | sed 's/^.*Device "\(.*\)" id.*$/\1/'  )


#--------penidは、pendiviceのID
penid=$(echo $calinfo | sed 's/id=/\n/1;s/^.*\n//' | awk '{print $1}' )

#--------monidは、monitorのID
monid=$(echo $calinfo | awk '{print $NF}' )



#キャリブレーションを実行する部分
_calibration()

{

deviceid=$1

out=$(xinput_calibrator --device $deviceid)


wtot=$(echo $out | sed -n 's/.*max_x=\([0-9+-]*\).*/\1/p')
htot=$(echo $out | sed -n 's/.*max_y=\([0-9+-]*\).*/\1/p')


minx=$(echo $out | sed -n 's/.*MinX\"\s\"\([0-9+-]*\).*/\1/p')
maxx=$(echo $out | sed -n 's/.*MaxX\"\s\"\([0-9+-]*\).*/\1/p')
miny=$(echo $out | sed -n 's/.*MinY\"\s\"\([0-9+-]*\).*/\1/p')
maxy=$(echo $out | sed -n 's/.*MaxY\"\s\"\([0-9+-]*\).*/\1/p')




wtouch=$(bc <<< "$maxx - $minx")
htouch=$(bc <<< "$maxy - $miny")



c0=$(bc -l <<< "$wtot / $wtouch")
c1=$(bc -l <<< "-1*$minx / $wtouch")
c2=$(bc -l <<< "$htot / $htouch")
c3=$(bc -l <<< "-1*$miny / $htouch")

tf_matrix="$c0 0 $c1 0 $c2 $c3 0 0 1"

echo $tf_matrix


#echo -e "To make this permanent, save the following content \n under '/etc/X11/xorg.conf.d/98-screen-calibration.conf' \n or '/usr/share/X11/xorg.conf.d/98-screen-calibration.conf'"
#echo "Section \"InputClass\""
#echo "	Identifier \"calibration\""
#echo "	MatchProduct \"$device\""
#echo "	Option \"TransformationMatrix\" \"$tf_matrix\""
#echo "EndSection"

}



#-------------以下ケースごとに作業を実施する。----------------



case  $pensw in
 
     10)
#         xinput map-to-output $penid $monid
        _calibration $penid  | tee  $HOME/caldo.txt
        caldofile=$HOME/caldo.txt
        caldolines=()
        while IFS= read -r caldolines; do

        caldolines=("${caldolines[@]}"  "$caldolines")
        done <"$caldofile"
        caldat=${caldolines[1]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
        bash $opdir/penctrl.sh

         ;;


     12) 
        caldofile=$HOME/caldo.txt
        caldolines=()
        while IFS= read -r caldolines; do

        caldolines=("${caldolines[@]}"  "$caldolines")
        done <"$caldofile"
        caldat=${caldolines[1]}
  
		calnew=$caldat 
		caladd=$(yad --title="キャリブレ登録変更" \
				--form \
				--field="CALデータ登録１":CB \
					"${callines[1]} ! "" ! ${calnew} " \
				--field="CALデータ登録2":CB \
					"${callines[2]} ! "" ! ${calnew} " \
				--field="CALデータ登録3":CB \
					"${callines[3]} ! "" ! ${calnew} " \
				--field="CALデータ登録4":CB \
					"${callines[4]} ! "" ! ${calnew} " \
				--field="CALデータ登録5":CB \
					"${callines[5]} ! "" ! ${calnew} " \
				--field="CALデータ登録6":CB \
					"${callines[6]} ! "" ! ${calnew} " \
				--buttons-layout=edge \
				--button="登録して戻る。":32 \
				--button="gtk-cancel":33 \
				--button="gtk-quit":35 )
     
#--------出力をcaliniのフォーマットにする。--------

					addsw=$?
						
					case  $addsw in
					32)
					echo ${caladd} | tr '|' '\n' |sed -n '$!p' | sed -e 's/^[ ]*//g'  > $HOME/calini.txt
					bash $opdir/penctrl.sh
					
					;;
					33)
					bash $opdir/penctrl.sh
					
					;;
					35)
					exit
					;;
					esac         
		;;
                 
     14)
     
		bash calmod.sh
		;;

     16)
        xinput disable $penid
        bash $opdir/penctrl.sh
		;;

     18)
        xinput enable $penid
        bash $opdir/penctrl.sh
		;;


     21)
  
        caldat=${callines[1]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
 		bash $opdir/penctrl.sh
		exit  0
         ;;

     22)
     
       caldat=${callines[2]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
 		bash $opdir/penctrl.sh
		exit  0
         ;;


     23)
     
       caldat=${callines[3]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
 		bash $opdir/penctrl.sh
		exit  0
         ;;


     24)
     
        caldat=${callines[4]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
 		bash $opdir/penctrl.sh
		exit  0
         ;;


     25)
     
       caldat=${callines[5]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
 		bash $opdir/penctrl.sh
		exit  0
         ;;


     26)
          
       caldat=${callines[6]}
        
        xinput set-prop $penid 'Coordinate Transformation Matrix'   $caldat
 		bash $opdir/penctrl.sh
		exit  0
         ;;


	 * )
	    exit 0
		;;
		
esac         

#---------バックアップファイルを削除する。

exit  0
 
