#!/bin/zsh

DEBUG=1
debug () {
    if [[ $DEBUG ]]; then
        print $@
    fi
}

if [[ $1 == "-h" || $1 == '--help' ]]; then
    print '$1 = file name - $2 = margins "<left> <top> <right> <bottom>" '
    print "Note that this script assumes that the pdf has only one size in every page"
    exit 0
fi


file=$1
margins=("${(s. .)2}")
folder_tmp=/tmp/folder_${file%.pdf}

# move in tmp
mkdir $folder_tmp
cp $file $folder_tmp
pushd $folder_tmp

# dimensions
infos=`pdfinfo $file | grep "Page size"`
infos=("${(s. .)infos}")
height=$infos[5]
width=$infos[3]

debug $infos $height $width

# check dimensions TODO

# crop
output=${file%.pdf}_margins.pdf

_crop_box="[/CropBox [$margins[1] $margins[4] $((width - margins[3])) $((height - margins[2]))]"
print $_crop_box
gs -o $output -sDEVICE=pdfwrite -c $_crop_box -c " /PAGES pdfmark" -f $file


# move 
popd
mv $folder_tmp/$output ./
rm -r $folder_tmp
exit 0
