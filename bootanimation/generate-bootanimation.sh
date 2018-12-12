#!/bin/bash
###
# Getting variables from the makefile
###

WIDTH="$1"
HEIGHT="$2"
HALF_RES="$3"
BOOTNUM="$4"
OUT="$ANDROID_PRODUCT_OUT/obj/BOOTANIMATIONS/$BOOTNUM"

rm -rf $OUT
mkdir -p $OUT

# unset BOOTNUM if = 0
if [[ $BOOTNUM = 0 ]]; then
    unset BOOTNUM
fi

# Randomly pick bootanimation, but make sure we don't pick same one multiple times.
RANDOM_BOOT=$(shuf -i 0-9 -n 1)
RANDOM_BOOT=9   #TEMP/DNM: make sure one of the bootanimations are bootanim #9
BOOTANIM_NUMS="$OUT/../.bootanimation_numbers"
if [[ -f $BOOTANIM_NUMS ]]; then
    until ! cat $BOOTANIM_NUMS | grep $RANDOM_BOOT &>/dev/null; do
        RANDOM_BOOT=$(shuf -i 0-9 -n 1)
    done
fi
touch $BOOTANIM_NUMS
echo $RANDOM_BOOT >> $BOOTANIM_NUMS
echo "Info: bootanimation was chosen randomly. The chosen one is the number $RANDOM_BOOT"

#####
# This is the main AICP code except adjusted to generate x bootanimations, randomly picked.
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

zip -qr0 "$OUT/bootanimation$BOOTNUM.zip" .
