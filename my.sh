echo "Start..."
rm /Users/liupeng/work/release/android/ting/*.apk

# #ues the mac  perl commond to replace old version config
perl -pi -w -e 's/android:versionCode="26"/android:versionCode="27"/g;' ~/work/ting_android/*/*.xml
perl -pi -w -e 's/android:versionName="4.0.4"/android:versionName="4.0.5"/g;' ~/work/ting_android/*/*.xml
perl -pi -w -e 's/4.0.4/4.0.5/g;' ~/work/ting_android/*/*/*/*.xml

#trans build
python /Users/liupeng/work/nstools/zhtools/Ting_Trans_Decode.py 

android update lib-project  --target 28 --path /Users/liupeng/work/ting_android/libprojects/abs
android update lib-project  --target 28 --path /Users/liupeng/work/ting_android/libprojects/library
android update lib-project  --target 28 --path  /Users/liupeng/work/ting_android/Eudict_Ting_Lib

BuildEn(){
	 android update  project --target 28 --path   /Users/liupeng/work/ting_android/Eudict_Ting_English
	 cd /Users/liupeng/work/ting_android/Eudict_Ting_English
	 ant clean
	 ant release
	 mv /Users/liupeng/work/ting_android/Eudict_Ting_English/bin/ting_en-release.apk  /Users/liupeng/work/release/android/ting/ting_en.apk
}
BuildFr(){
	}
BuildDe(){
	}
BuildEs(){
	
}
BuildAll(){
 BuildEn
 BuildEn
 BuildEn
 BuildEn
}
if [ -z "$1" ]
  then
    echo "No argument supplied,so build all app"
	BuildAll
else
	echo "====================="
	echo  $1
	echo "====================="
	if [ "$1" = "en" ]
	then
	  echo "Start en"
	  BuildEn
	elif [ "$1" = "fr" ]
		then
		  echo "Start fr"
		  BuildFr 
  	elif [ "$1" = "de" ]
  		then
  		  echo "Start de"
		  BuildDe
    elif [ "$1" = "es" ]
    		then
    		  echo "Start es"
			  BuildEs
	else
		echo "Wrong"
		exit
	fi
fi
# SendFtp
exit