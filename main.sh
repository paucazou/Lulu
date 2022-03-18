#!/bin/zsh


margin_rasterize_paper() {
    if [[ $1 == "-h" ]]; then
        print '$1 = file; $2 = margin; $3 = paper (a4, a5...) OR $3 = WIDTH AND $4 = HEIGHT'
    else
    file_name=${1%%.pdf}
    tmp_file=/tmp/$file_name
    margin=$2
    paper=$3
    # margin
    print Adding margins...
    pdfcrop --margins $margin $1 $tmp_file.pdf
    # to ps
    #print Removing fonts...
    #pdf2ps $tmp_file.pdf /tmp/$file_name.ps
    # back to pdf
    #print ...from PDF
    #ps2pdf /tmp/$file_name.ps /tmp/$file_name.pdf
    print Embedding fonts...
    gs -q -dNOPAUSE -dBATCH -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite -sOutputFile=$tmp_file.1.pdf $tmp_file.pdf
    mv $tmp_file.1.pdf $tmp_file.pdf
    # paper size
    if [[ $4 != '' ]] ; then
        print To ${3}x${4}...
        sized_file=${file_name}_rasterized_${3}x${4}.pdf
        pdfjam /tmp/$file_name.pdf --papersize "'"'{'$3,$4'}'"'" --outfile /tmp/$sized_file
    else
        print To $3...
        sized_file=${file_name}_rasterized_${3}.pdf
        pdfjam /tmp/$file_name.pdf --${3}paper --outfile /tmp/$sized_file
    fi
    mv /tmp/$sized_file $sized_file
    # compressing
    #print Compressing file...
    #gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH  -dQUIET -sOutputFile=$sized_file /tmp/$sized_file
    fi
}

