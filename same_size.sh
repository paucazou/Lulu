#!/bin/zsh
# This script takes a PDF file with pages of different size,
# takes the larger width and height,
# extend each page to this larger size
# and center the content

file=$1

# Number of pages
_pages=`pdfinfo $file | grep Pages`
nbpages=${(s. .)_pages#Pages:} # Yeah, it's ugly, it's zsh!
nbpages=${nbpages//[[:space:]]/}
print Number of pages: $nbpages

# Max width and height
_sizes=`pdfinfo -l $nbpages $file | grep -E 'size.*pts'`
_max=`python -c "\
sizes = '''$_sizes'''.split('\n'); \
sizes = [[ x.split()[3], x.split()[5]] for x in sizes if x ]; \
w = max( [float(x[0]) for x in sizes]); \
h = max( [float(x[1]) for x in sizes]); \
print(f'{w}x{h}'); \
"`
max=(${(s.x.)_max})
print Max found: $max

# split file
folder=/tmp/folder_${file%.pdf}
mkdir $folder
cp $file $folder
pushd $folder
pdftk $file burst
rm $file

# extend size
margin () {
    ((x = ($1 - $2) / 2))
    print -$x
}

for f in *.pdf; do
    print $f
    size=`pdfinfo $f | grep size`
    infos=("${(s. .)size}")
    w=$infos[3]
    h=$infos[5]
    w_=`margin $max[1] $w`
    h_=`margin $max[2] $h`

    cpdf -mediabox "${w_}pt ${h_}pt $max[1] $max[2]" $f -o ${f%.pdf}.page
    #pdfcrop --margins "${w_} ${h_}" $f  ${f%.pdf}.page
done

# merging files
nfile=${file%.pdf}_sized.pdf
pdftk *.page cat output $nfile
popd
mv $folder/$nfile ./
rm -r $folder



