#!/bin/bash
###
# Getting variables from the makefile
###

WIDTH="$1"
HEIGHT="$2"
HALF_RES="$3"
SINGLE_BOOT="$4"
BOOTNUM="$5"

if [ "$SINGLE_BOOT" = "false" ]; then
OUT="$ANDROID_PRODUCT_OUT/obj/BOOTANIMATIONS/$BOOTNUM"
else
OUT="$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/"
fi

# remove OUT if it already exists
if [[ -d $OUT ]]; then
    rm -rf $OUT
fi
mkdir -p "$OUT/bootanimation"

#####
# This is the main AICP code except adjusted to generate 3 bootanimations.
#
# By now the current designs to declare are:
#   0: Classic bootanimation
#   1: Classic bootanimation but without the "Provided by team bootleggers" and go straight to the loop.
#   2: Attempt of glitch made by us, bad attempt but it's clean anyways
#   3: After effects reveal template: It's a template, more than that what do you expect?
#   4: After effects reveal template (alternative): Another template but it got a circle except of lines and more glitching at the end.
#   5: Moelle's CRT: Show the logo on a kind of CRT screen
#   6: Moelle's Glitch Reveal: A very dark but glitchy way to show our logo, that ends on a CRT style.
#   7: Moelle's Hackled: Shows more glitch but it loads the software on a monotype font style.
#   8: Moelle's Shining Logo: A LED-Alike logo that glitches out and and ends showing up the ROM name with the main logo font
#   9: Moelle's Smoke Pulse: The one that got shared everywhere, that ends on a smokey background.
#
#####

if [ "$SINGLE_BOOT" = "false" ]; then

RANDOM_BOOT=$(shuf -i 0-9 -n 1)
BOOTANIM_NUMS="$OUT/../.bootanimation_numbers"
if [[ -f $BOOTANIM_NUMS ]]; then
    until ! cat $BOOTANIM_NUMS | grep $RANDOM_BOOT &>/dev/null; do
        RANDOM_BOOT=$(shuf -i 0-9 -n 1)
    done
fi
touch $BOOTANIM_NUMS
echo $RANDOM_BOOT >> $BOOTANIM_NUMS
echo "Info: bootanimation was chosen randomly. The chosen one is the number $RANDOM_BOOT"

else

if [ -z "$BOOTNUM" ]; then
    RANDOM_BOOT=$(shuf -i 0-9 -n 1)
    echo "Info: bootanimation was chosen randomly. The chosen one is the number $RANDOM_BOOT"
else
    if [ $BOOTNUM -lt -1 ] || [ $BOOTNUM -gt 9 ]; then
        echo "ERROR: The declared value isn't on the bootanimation list bounds. Please refer to generate-bootanimation.sh to see the values"
        exit 1
    else
        RANDOM_BOOT="$BOOTNUM"
        echo "Info: bootanimation was chosen manually. The chosen one is the number $RANDOM_BOOT"
    fi
fi

fi

case "$RANDOM_BOOT" in
    [0-1])
        BOOTFPS="30"
        ISQUARE="true"
    ;;

    2)
        BOOTFPS="48"
        ISQUARE="true"
    ;;

    [3-4])
        BOOTFPS="50"
        ISQUARE="false"
    ;;

    [5-7])
        BOOTFPS="25"
        ISQUARE="false"
    ;;

    [8-9])
        BOOTFPS="30"
        ISQUARE="false"
    ;;

    *)
        echo "Info: Something went wrong at the time of taking the number."
esac

###
# This is the size declaration and adjustments acording a TARGET_BOOTANIMATION_HALF_RES
###

if [ -z "$WIDTH" ]; then
    echo "Warning: bootanimation width not specified"
    WIDTH="1080"
fi
 if [ -z "$HEIGHT" ]; then
    echo "Warning: bootanimation height not specified"
    HEIGHT="1920"
fi

if [ "$HEIGHT" -lt "$WIDTH" ]; then
    SQUARESIZE="$HEIGHT"
else
    SQUARESIZE="$WIDTH"
fi

if [ "$HALF_RES" = "true" ] && [ "$ISQUARE" = "true" ]; then
    IMAGESIZEH=$(expr $SQUARESIZE / 2)
    IMAGESIZEW=$(expr $SQUARESIZE / 2)
elif [ "$HALF_RES" = "true" ] && [ "$ISQUARE" = "false" ]; then
    IMAGESIZEH=$(expr $HEIGHT / 2)
    IMAGESIZEW=$(expr $WIDTH / 2)
elif [ "$ISQUARE" = "true" ]; then
    IMAGESIZEH="$SQUARESIZE"
    IMAGESIZEW="$SQUARESIZE"
else
    IMAGESIZEH="$HEIGHT"
    IMAGESIZEW="$WIDTH"
fi

RESOLUTION=""$IMAGESIZEW"x"$IMAGESIZEH""
for part_cnt in 0 1 2; do
    mkdir -p $OUT/bootanimation/part$part_cnt
done
tar xfp "vendor/bootleggers/bootanimation/bootanimation$RANDOM_BOOT.tar" --to-command="convert - -strip -gaussian-blur 0.05 -quality 55 -resize '$RESOLUTION'^ -gravity center -crop '$RESOLUTION+0+0' +repage \"$OUT/bootanimation/\$TAR_FILENAME\""

# Create desc.txt
echo "$IMAGESIZEW $IMAGESIZEH" "$BOOTFPS" > "$OUT/bootanimation/desc.txt"
cat "vendor/bootleggers/bootanimation/desc.txt" >> "$OUT/bootanimation/desc.txt"

# Create bootanimation.zip
cd "$OUT/bootanimation"

if [ "$SINGLE_BOOT" = "false" ]; then
zip -qr0 "$OUT/bootanimation$BOOTNUM.zip" .
else
zip -qr0 "$OUT/bootanimation.zip" .
fi
