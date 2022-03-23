#!/bin/zsh

# TODO rajouter un moyen d'affiner la coupe centrale, au cas où la page soit mal centrée
if [[ $1 == "-h" || $1 == '--help' ]]; then
    print '$1 = file name - $2 = margins "<left> <top> <right> <bottom>" - $3 = --try (first page only)(not required)'
    exit 0
fi


file=$1
margins=("${(s. .)2}")
if [[ $3 == '--try' ]]; then
    try=1
else
    try=0
fi
folder_tmp=/tmp/folder_${file%.pdf}

# move in tmp
mkdir $folder_tmp
cp $file $folder_tmp
pushd $folder_tmp

# split in multiple files
if [[ $try == 1 ]]; then
    pdftk $file cat 1 output 1.pdf
else
    pdftk $file burst
    rm doc_data.txt
fi

rm $file

pg_nb=0
zeroes=0000
for f in *.pdf; do
    # dimensions
    infos=`pdfinfo $f | grep "Page size"`
    infos=("${(s. .)infos}")
    height=$infos[5]
    width=$infos[3]
    # check dimensions TODO
    # first page
    name=${zeroes:0:((${#zeroes}-${#pg_nb}))}$pg_nb.page
    pdfcrop --margins "-$margins[1] -$margins[2] -$((width/2)) -$margins[4]" $f $name
    ((pg_nb=pg_nb+1))
    # second page
    name=${zeroes:0:((${#zeroes}-${#pg_nb}))}$pg_nb.page
    pdfcrop --margins "-$((width/2)) -$margins[2] -$margins[3] -$margins[4]" $f $name
    ((pg_nb=pg_nb+1))
    # remove base file
    rm $f
done

# catenate files
output=${file%.pdf}_split.pdf
pdftk *.page cat output $output
popd
mv $folder_tmp/$output ./
rm -r $folder_tmp
exit 0
