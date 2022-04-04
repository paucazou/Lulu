#!/usr/bin/python3
# -*-coding:Utf-8 -*
#Deus, in adjutorium meum intende
# This scripts aims to fix these Ghostscript error: too many Q's, Error reading a content stream, etc.

import pathlib as pl
import PyPDF2 as ppdf
import sys

filename = sys.argv[1]
new_filename = f"{pl.Path(filename).stem}_fixed.pdf"

old_pdf = ppdf.PdfFileReader(open(filename, 'rb'))
new_pdf = ppdf.PdfFileWriter()

for i,page in enumerate(old_pdf.pages):
    try:
        del(page.getContents()[1])
    except (IndexError,KeyError):
        print(f"Index error in page {i}")
    new_pdf.addPage(page)

new_pdf.write(open(new_filename, 'wb'))





