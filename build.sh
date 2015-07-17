#!/bin/sh
export PATH=/opt/local/bin/:/opt/local/sbin:$PATH:/usr/local/bin:

convertPath=`which convert`
echo ${convertPath}
if [[ ! -f ${convertPath} || -z ${convertPath} ]]; then
    echo "WARNING: Skipping Icon versioning, you need to install ImageMagick, you can use brew to simplify process:
    brew install imagemagick"
exit 0;
fi

gsPath=`which gs`
echo ${gsPath}
if [[ ! -f ${gsPath} || -z ${gsPath} ]]; then
    echo "WARNING: Skipping Icon versioning, you need to install ghostscript (fonts) first, you can use brew to simplify process:
    brew install ghostscript"
exit 0;
fi

CDIR="$PWD"
echo 'cdir:'$CDIR
PROJECT_NAME='Demo'
INFOPLIST_FILE=$CDIR"/$PROJECT_NAME/$PROJECT_NAME-Info.plist"
echo $INFOPLIST_FILE
ICON_FOLDER=$CDIR"/$PROJECT_NAME/Resources/Images.xcassets/AppIcon.appiconset"
echo $ICON_FOLDER

git=`sh /etc/profile; which git`
build_num=`"$git" rev-list --all |wc -l`
branch=`"$git" rev-parse --abbrev-ref HEAD`
commit=`"$git" rev-parse --short HEAD`
# version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}")
version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLIST_FILE}")

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

branch="${branch}->${BUNDLE_DISPLAY_NAME_SUFFIX}"

shopt -s extglob
build_num="${build_num##*( )}"
shopt -u extglob
caption="${version} ($build_num)\n${branch}\n${commit}"
echo $caption

function processIcon() {
    base_path=$1
	width=`identify -format %w ${base_path}`
	height=`identify -format %h ${base_path}`
	band_height=$((($height * 47) / 100))
	band_position=$(($height - $band_height))
	text_position=$(($band_position - 3))
	point_size=$(((13 * $width) / 100))

	echo "Image dimensions ($width x $height) - band height $band_height @ $band_position - point size $point_size"

	#
	# blur band and text
	#
	tempPath=$CDIR/tmp/
	mkdir $CDIR/tmp/

	convert ${base_path} -blur 10x8 ${tempPath}blurred.png
	convert ${tempPath}blurred.png -gamma 0 -fill white -draw "rectangle 0,$band_position,$width,$height" ${tempPath}mask.png
	convert -size ${width}x${band_height} xc:none -fill 'rgba(0,0,0,0.2)' -draw "rectangle 0,0,$width,$band_height" ${tempPath}labels-base.png
	convert -background none -size ${width}x${band_height} -pointsize $point_size -fill white -gravity center -gravity South caption:"$caption" ${tempPath}labels.png

	convert ${base_path} ${tempPath}blurred.png ${tempPath}mask.png -composite ${tempPath}temp.png

	rm $base_path
	convert ${tempPath}temp.png ${tempPath}labels-base.png -geometry +0+$band_position -composite ${tempPath}labels.png -geometry +0+$text_position -geometry +${w}-${h} -composite $base_path

	# clean up
	rm -rf ${tempPath}
}

if [ -d "$ICON_FOLDER" ]; then
	echo 'got file'
	cp -R $ICON_FOLDER $ICON_FOLDER"_temp"
else
	echo 'have not found icon res ,so eixt'
	exit
fi
for file in $(find $ICON_FOLDER -name "*.png")
do
echo "processIcon:"$file
processIcon $file
done
exit

# git reset --hard ${branch}

# function ask {
#     while true; do
#
#         if [ "${2:-}" = "Y" ]; then
#             prompt="Y/n"
#             default=Y
#         elif [ "${2:-}" = "N" ]; then
#             prompt="y/N"
#             default=N
#         else
#             prompt="y/n"
#             default=
#         fi
#
#         # Ask the question
#         read -p "$1 [$prompt] " REPLY
#
#         # Default?
#         if [ -z "$REPLY" ]; then
#             REPLY=$default
#         fi
#
#         # Check if the reply is valid
#         case "$REPLY" in
#             Y*|y*) return 0 ;;
#             N*|n*) return 1 ;;
#         esac
#
#     done
# }
#
# echo 'found below plist file'
# find *.plist
# echo 'which plist is main...?'
#
# targetPlist=''
# for file in *.plist
# do
# echo $file
# if ask "this file ??? "; then
# 	targetPlist=$file
# 	echo "got: "$targetPlist
# else
# 	echo '--next-'
# fi
# done
#
# if [ -z "$targetPlist" ] ;then
# 	echo "need set main plist"
# 	exit
# fi
#
# echo 'do something on plist'